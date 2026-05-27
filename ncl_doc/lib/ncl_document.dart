library ncl_document;

import 'dart:async';
import 'xml_elements.dart';
import 'parser.dart';

import 'event.dart';

export 'xml_elements.dart';
export 'parser.dart';
export 'lua.dart';
export 'event.dart';

enum State { OCCURRING, PAUSED, SLEEPING }

class NCLDocument {
  final List<NCLXMLElement> elements;
  Context? _root;
  Settings? _settings;

  int virtualClock = 0;
  final List<Action> _actionQueue = [];
  Timer? _timer;

  NCLDocument(String xml) : elements = <NCLXMLElement>[] {
    final parsed = NCLParser().parseString(xml);
    elements.addAll(parsed.elements);
    _initializeRootAndSettings();
    _setupEventStateListeners();
    _processPorts();
  }

  NCLDocument.fromElements([List<NCLXMLElement>? initialElements])
      : elements = initialElements != null
            ? List<NCLXMLElement>.from(initialElements)
            : <NCLXMLElement>[] {
    _initializeRootAndSettings();
    _setupEventStateListeners();
    _processPorts();
  }

  void _initializeRootAndSettings() {
    final contexts = elements.whereType<Context>();
    if (contexts.isNotEmpty) {
      _root = contexts.first;
    } else {
      _root = Context(id: '__root__');
      elements.add(_root!);
    }

    final settingsList = elements.whereType<Settings>();
    if (settingsList.isNotEmpty) {
      _settings = settingsList.first;
    } else {
      _settings = Settings(id: 'default_settings');
      _root!.children.add(_settings!);
      _settings!.parent = _root;
      elements.add(_settings!);
    }

    for (var node in elements.whereType<Node>()) {
      for (var child in node.children.whereType<Property>()) {
        if (child.name != null && child.value != null) {
          node.setProperty(child.name!, child.value!);
        }
      }
    }
  }

  Context? getRoot() => _root;

  Settings? getSettings() => _settings;

  Node? getNodeById(String id) {
    final nodes = elements.whereType<Node>().where((n) => n.id == id);
    return nodes.isEmpty ? null : nodes.first;
  }

  void _setupEventStateListeners() {
    for (var node in elements.whereType<Node>()) {
      node.lambda.addStateListener((oldState, newState) {
        print(
          '[Clock: $virtualClock] Node "${node.id}" changed state: '
          '${Event.getEventStateAsString(oldState)} -> ${Event.getEventStateAsString(newState)}',
        );
        _triggerLinks(node.id, newState);
      });
    }
  }

  void _processPorts() {
    for (var port in elements.whereType<Port>()) {
      if (port.component != null) {
        final node = getNodeById(port.component!);
        if (node != null) {
          node.startTimestamp = 0;
          final event = node.lambda;
          _scheduleAction(event, ActionType.START);
        }
      }
    }
  }

  State getLambdaState(String targetId) {
    final node = getNodeById(targetId);
    return node?.lambda.state ?? State.SLEEPING;
  }

  void setEventState(String targetId, State newState) {
    final node = getNodeById(targetId);
    if (node == null) return;
    node.lambda.state = newState;
  }

  void tick([int increment = 1]) {
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

    final links = context is Context
        ? context.links
        : elements.whereType<Link>().toList();

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
              final event = bindNode.lambda;
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

  void start({int ticksPerSecond = 10}) {
    stop();
    final interval = Duration(milliseconds: 1000 ~/ ticksPerSecond);
    _timer = Timer.periodic(interval, (timer) {
      if (_actionQueue.isEmpty) {
        stop();
        print('Execution finished. Total virtual time: $virtualClock');
        return;
      }
      tick();
    });
  }

  void stop() {
    _timer?.cancel();
    _timer = null;
  }
}
