/// Support for NCL execution in headless mode.
library ncl_vm;

import 'dart:async';
import 'parser.dart';
import 'document.dart';
import 'xml_elements.dart';

export 'xml_elements.dart';
export 'parser.dart';
export 'document.dart';
export 'lua.dart';

class NCLVM {
  final NCLParser _parser = NCLParser();
  late final Document document;
  int virtualClock = 0;
  final List<Action> _actionQueue = [];
  Timer? _timer;

  NCLVM(String xml) {
    document = _parser.parseString(xml);
    _processPorts();
  }

  NCLVM.fromDocument(this.document) {
    _processPorts();
  }

  void _processPorts() {
    for (var port in document.elements.whereType<Port>()) {
      if (port.component != null) {
        final node = document.getNodeById(port.component!);
        if (node != null) {
          node.startTimestamp = 0;
          final event = node.lambda;
          _scheduleAction(event, ActionType.START);
        }
      }
    }
  }

  State getLambdaState(String targetId) {
    final node = document.getNodeById(targetId);
    return node?.lambda.state ?? State.SLEEPING;
  }

  void setEventState(String targetId, State newState) {
    final node = document.getNodeById(targetId);
    if (node == null) return;

    final currentState = node.lambda.state;
    if (currentState == newState) return;

    node.lambda.state = newState;
    print(
      '[Clock: $virtualClock] Node "$targetId" changed state: '
      '${Event.getEventStateAsString(currentState)} -> ${Event.getEventStateAsString(newState)}',
    );
    _triggerLinks(targetId, newState);
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

      final currentState = getLambdaState(actionItem.event.targetNode.id);
      final nextState = actionItem.event.doAction(actionItem.action);

      if (currentState != nextState) {
        print(
          '[Clock: $virtualClock] Node "${actionItem.event.targetNode.id}" changed state: '
          '${Event.getEventStateAsString(currentState)} -> ${Event.getEventStateAsString(nextState)}',
        );
        _triggerLinks(actionItem.event.targetNode.id, nextState);
      }
    }

    virtualClock = time;
  }

  void _triggerLinks(String targetId, State newState) {
    final node = document.getNodeById(targetId);
    final context = node?.parent;

    final links = context is Context
        ? context.links
        : document.elements.whereType<Link>().toList();

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
            final bindNode = document.getNodeById(bind.component!);
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
