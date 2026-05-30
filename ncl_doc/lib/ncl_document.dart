library;

import 'dart:async';

import 'package:logging/logging.dart';

import 'event.dart';
import 'parser.dart';
import 'xml_elements.dart';

export 'event.dart';
export 'lua.dart';
export 'parser.dart';
export 'xml_elements.dart';

enum State { OCCURRING, PAUSED, SLEEPING }

final _logger = Logger('ncl_doc');

class NCLDocument {
  late final Head? _head;
  late final Context _body;
  late final Settings _settings;

  int virtualClock = 0;
  bool isPlaying = false;
  final List<Action> _actionStack = [];
  final List<Node> _timedNodes = [];

  factory NCLDocument.fromBodyElements(List<NCLXMLElement> elements) {
    final body = Context(id: 'body');
    body.children.addAll(elements);
    for (var el in elements) {
      if (el is Node) {
        el.parent = body;
      }
    }
    return NCLDocument(body: body);
  }

  factory NCLDocument.fromXML(String xml) {
    final (head, body) = NCLParser().parseString(xml);
    return NCLDocument(head: head, body: body);
  }

  NCLDocument({Head? head, required Body body}) {
    _head = head;
    _body = body;
    _init();
  }

  void _init() {
    _gatherSettings();
    _gatherTimedNodes();
    _stackMainEvtAction(_body, ActionType.START);
    _stackPorts(_body);
  }

  void _gatherSettings() {
    final settingsList = _body.children.whereType<Settings>();
    if (settingsList.isNotEmpty) {
      _settings = settingsList.first;
    } else {
      _settings = Settings(id: '__settings__');
      _body.children.add(_settings);
      _settings.parent = _body;
    }
  }

  void _gatherTimedNodes() {
    void gather(Composition comp) {
      for (var node in comp.getNodes()) {
        if (node.explicitDurMs != null) {
          _timedNodes.add(node);
        }
        if (node is Composition) {
          gather(node);
        }
      }
    }

    gather(_body);
  }

  Head? getHead() => _head;
  Context getBody() => _body;
  State getBodyState() => _body.getMainState();

  Settings getSettings() => _settings;

  Node? getNodeById(String id) {
    if (_body.id == id) return _body;

    Node? search(Composition comp) {
      for (var node in comp.getNodes()) {
        if (node.id == id) return node;
        if (node is Composition) {
          final res = search(node);
          if (res != null) return res;
        }
      }
      return null;
    }

    return search(_body);
  }

  List<Media> getActiveMedia() {
    final active = <Media>[];
    void search(Composition comp) {
      for (var node in comp.getNodes()) {
        if (node is Media && node.getMainState() == State.OCCURRING) {
          active.add(node);
        } else if (node is Composition) {
          search(node);
        }
      }
    }

    search(_body);
    return active;
  }

  void _stackPorts(Context comp) {
    for (var port in comp.getPorts()) {
      if (port.component != null) {
        final node = getNodeById(port.component!);
        if (node != null) {
          _stackMainEvtAction(node, ActionType.START);
          if (node is Context) {
            _stackPorts(node);
          }
        }
      }
    }
  }

  void tick([int incrementMs = 0]) {
    _updateTimedNodesClock(incrementMs);
    _executeActionStack();
    _checkIsPlaying();
  }

  void _updateTimedNodesClock(int incrementMs) {
    final targetTime = virtualClock + incrementMs;
    if (targetTime < virtualClock) return;

    int delta = targetTime - virtualClock;
    if (delta > 0) {
      for (var node in _timedNodes) {
        if (node.getMainState() == State.OCCURRING) {
          node.time += delta;
          if (node.time >= node.explicitDurMs!) {
            _logger.info(
              '[Clock: ${(targetTime / 1000).toStringAsFixed(3)}s] Node "${node.id}" reached explicit duration (${node.explicitDurMs}ms)',
            );
            _stackMainEvtAction(node, ActionType.STOP);
          }
        }
      }
      virtualClock = targetTime;
    }
  }

  void _executeActionStack() {
    while (_actionStack.isNotEmpty) {
      final actionItem = _actionStack.removeAt(0);
      final prevState = actionItem.event.state;
      actionItem.event.doAction(actionItem.action);
      final newState = actionItem.event.state;
      if (actionItem.event.isMain && newState != prevState) {
        _logger.info(
          '[Clock: ${(virtualClock / 1000).toStringAsFixed(3)}s] Node "${actionItem.event.targetNode.id}" changed state: ${Event.getEventStateAsString(prevState)} -> ${Event.getEventStateAsString(newState)}',
        );
        if (newState == State.OCCURRING) {
          actionItem.event.targetNode.time = 0;
          if (actionItem.event.targetNode is Context) {
            _stackPorts(actionItem.event.targetNode as Context);
          }
        }
        _triggerLinks(actionItem.event.targetNode.id, newState);
        final parent = actionItem.event.targetNode.parent;
        if (parent is Context) {
          if (newState == State.OCCURRING) {
            parent.activeNodes++;
          } else if (newState == State.SLEEPING) {
            if (parent.activeNodes > 0) parent.activeNodes--;
            if (parent.activeNodes == 0) {
              _stackMainEvtAction(parent, ActionType.STOP);
            }
          }
        }
      }
    }
  }

  void _checkIsPlaying() {
    if (_actionStack.isEmpty && _body.getMainState() == State.SLEEPING) {
      isPlaying = false;
    }
  }

  void _triggerLinks(String targetId, State newState) {
    final node = getNodeById(targetId);
    final context = node?.parent;

    final links = context is Context ? context.getLinks() : _body.getLinks();

    for (var link in links) {
      bool triggered = false;
      if (newState == State.OCCURRING) {
        triggered = link.children.whereType<Bind>().any(
          (b) => b.role == 'onBegin' && b.component == targetId,
        );
      } else if (newState == State.SLEEPING) {
        triggered = link.children.whereType<Bind>().any(
          (b) => b.role == 'onEnd' && b.component == targetId,
        );
      }

      if (triggered) {
        for (var bind in link.children.whereType<Bind>().where(
          (b) => b.role == 'start',
        )) {
          if (bind.component != null) {
            final bindNode = getNodeById(bind.component!);
            if (bindNode != null) {
              _stackMainEvtAction(bindNode, ActionType.START);
            }
          }
        }
      }
    }
  }

  void _stackMainEvtAction(Node node, ActionType actionType) {
    _stackAction(node.getMainEvent(), actionType);
  }

  void _stackAction(Event event, ActionType actionType) {
    _actionStack.add(Action(event: event, action: actionType));
  }

  void start() {
    _logger.info('[Clock: ${virtualClock / 1000}s] NCLDocument will start');
    isPlaying = true;
    tick();
  }

  void tickIndefinitely({int ticksPerSecond = 10, void Function()? onStop}) {
    if (!isPlaying) {
      onStop?.call();
      return;
    }
    _logger.info(
      '[Clock: ${virtualClock / 1000}s] NCLDocument will tick indefinitely at $ticksPerSecond ticks per second',
    );
    final interval = Duration(milliseconds: 1000 ~/ ticksPerSecond);
    Timer.periodic(interval, (timer) {
      if (!isPlaying) {
        timer.cancel();
        onStop?.call();
        return;
      }
      tick(interval.inMilliseconds);
      _logger.info('[Clock: ${virtualClock / 1000}s] Tick');
    });
  }

  void stop() {
    _logger.info('[Clock: ${virtualClock / 1000}s] NCLDocument will stop');

    void stopNode(Node node) {
      if (node.getMainState() == State.OCCURRING ||
          node.getMainState() == State.PAUSED) {
        if (node is Composition) {
          for (var child in node.getNodes()) {
            stopNode(child);
          }
        }
        node.getMainEvent().doAction(ActionType.STOP);
      }
    }

    stopNode(_body);
  }
}
