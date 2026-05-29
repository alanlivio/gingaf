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
  final List<Action> _actionQueue = [];
  Timer? _timer;

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
    _initializeBodyAndSettings();
    _setupEventStateListeners();
    _processPorts();
  }

  void _initializeBodyAndSettings() {
    final settingsList = _body.children.whereType<Settings>();
    if (settingsList.isNotEmpty) {
      _settings = settingsList.first;
    } else {
      _settings = Settings(id: '__settings__');
      _body.children.add(_settings);
      _settings.parent = _body;
    }
  }

  Head? getHead() => _head;
  Context getBody() => _body;
  State getBodyState() => _body.getNodeState();

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

  void _setupEventStateListeners() {
    void addListener(Node node) {
      node.getNodeEvent().addStateListener((oldState, newState) {
        _logger.info(
          '[Clock: $virtualClock] Node "${node.id}" changed state: '
          '${Event.getEventStateAsString(oldState)} -> ${Event.getEventStateAsString(newState)}',
        );
        _triggerLinks(node.id, newState);
      });
      if (node is Composition) {
        for (var child in node.getNodes()) {
          addListener(child);
        }
      }
    }

    addListener(_body);
  }

  void _processPorts() {
    _body.startTimestamp = 0;
    _scheduleAction(_body.getNodeEvent(), ActionType.START);

    void process(Context comp) {
      for (var port in comp.getPorts()) {
        if (port.component != null) {
          final node = getNodeById(port.component!);
          if (node != null) {
            node.startTimestamp = 0;
            final event = node.getNodeEvent();
            _scheduleAction(event, ActionType.START);
          }
        }
      }
      for (var child in comp.getNodes()) {
        if (child is Context) {
          process(child);
        }
      }
    }

    process(_body);
  }

  void setEventState(String targetId, State newState) {
    final node = getNodeById(targetId);
    if (node == null) return;
    node.getNodeEvent().state = newState;
  }

  void tick([int increment = 0]) {
    tickTo(virtualClock + increment);
  }

  void tickTo(int time) {
    if (time < virtualClock) return;

    while (_actionQueue.isNotEmpty &&
        _actionQueue.first.event.targetNode.startTimestamp <= time) {
      final actionItem = _actionQueue.removeAt(0);
      virtualClock = actionItem.event.targetNode.startTimestamp;
      actionItem.event.doAction(actionItem.action);
    }

    virtualClock = time;
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
              bindNode.startTimestamp = virtualClock;
              final event = bindNode.getNodeEvent();
              _scheduleAction(event, ActionType.START);
            }
          }
        }
      }
    }
  }

  void _scheduleAction(Event event, ActionType actionType) {
    _actionQueue.add(Action(event: event, action: actionType));
  }

  void start() {
    _logger.info('[Clock: $virtualClock] NCLDocument will start');
    tick();
  }

  void tickIndefinitely({int ticksPerSecond = 10}) {
    _logger.info(
      '[Clock: $virtualClock] NCLDocument will tick indefinitely at $ticksPerSecond ticks per second',
    );
    _timer?.cancel();
    _timer = null;
    final interval = Duration(milliseconds: 1000 ~/ ticksPerSecond);
    _timer = Timer.periodic(interval, (timer) {
      if (getBodyState() == State.SLEEPING) {
        _timer?.cancel();
        _timer = null;
        return;
      }
      tick(1);
      _logger.info('[Clock: $virtualClock] Tick');
    });
  }

  void stop() {
    _logger.info('[Clock: $virtualClock] NCLDocument will stop');
    _timer?.cancel();
    _timer = null;

    void stopNode(Node node) {
      if (node.getNodeState() == State.OCCURRING ||
          node.getNodeState() == State.PAUSED) {
        node.getNodeEvent().doAction(ActionType.STOP);
      }
      if (node is Composition) {
        for (var child in node.getNodes()) {
          stopNode(child);
        }
      }
    }

    stopNode(_body);
  }
}
