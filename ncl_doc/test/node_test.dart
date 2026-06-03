import 'package:ncl_doc/xml_elements.dart';
import 'package:ncl_doc/event.dart';
import 'package:test/test.dart';

void main() {
  group('Node Tests', () {
    test('Media Node can return its properties and areas', () {
      final media = Media(id: 'video1');
      final prop = Property(
        id: 'p1',
        rawAttributes: {'name': 'bounds', 'value': '0,0,100,100'},
      );
      final area = Area(id: 'a1', rawAttributes: {'begin': '10s'});
      media.children.addAll([prop, area]);

      expect(media.getProperties().length, 1);
      expect(media.getProperties().first.name, 'bounds');
      expect(media.getProperties().first.value, '0,0,100,100');

      expect(media.getAreas().length, 1);
      expect(media.getAreas().first.begin, '10s');
    });

    test('Context Node can return its properties and areas', () {
      final context = Context(id: 'ctx1');
      final prop = Property(
        id: 'p1',
        rawAttributes: {'name': 'bounds', 'value': '0,0,100,100'},
      );
      final area = Area(id: 'a1', rawAttributes: {'begin': '10s'});
      context.children.addAll([prop, area]);

      expect(context.getProperties().length, 1);
      expect(context.getProperties().first.name, 'bounds');
      expect(context.getProperties().first.value, '0,0,100,100');

      expect(context.getAreas().length, 1);
      expect(context.getAreas().first.begin, '10s');
    });

    test('getMainEvent on Node returns same Event instance', () {
      final media = Media(id: 'm1');
      final event1 = media.getMainEvent();
      final event2 = media.getMainEvent();
      expect(event1, same(event2));
      expect(event1.targetNode.id, 'm1');
      expect(event1.type, EventType.PRESENTATION);
    });

    test('getAreaEventState returns state of the area event', () {
      final media = Media(id: 'm1');
      expect(media.getAreaEventState('a1'), State.SLEEPING);
      media.getAreaEvent('a1').state = State.OCCURRING;
      expect(media.getAreaEventState('a1'), State.OCCURRING);
    });

    test('doAction', () {
      final media = Media(id: 'm1');
      final event = media.getMainEvent();
      expect(event.state, State.SLEEPING);
      expect(event.doAction(ActionType.START), State.OCCURRING);
      expect(event.state, State.OCCURRING);
      expect(event.doAction(ActionType.PAUSE), State.PAUSED);
      expect(event.state, State.PAUSED);
      expect(event.doAction(ActionType.RESUME), State.OCCURRING);
      expect(event.state, State.OCCURRING);
      expect(event.doAction(ActionType.STOP), State.SLEEPING);
      expect(event.state, State.SLEEPING);
    });

    test(
      'doAction does not change state on invalid transitions from SLEEPING',
      () {
        final media = Media(id: 'm1');
        final event = media.getMainEvent();
        expect(event.state, State.SLEEPING);
        expect(event.doAction(ActionType.STOP), State.SLEEPING);
        expect(event.doAction(ActionType.ABORT), State.SLEEPING);
        expect(event.doAction(ActionType.PAUSE), State.SLEEPING);
        expect(event.doAction(ActionType.RESUME), State.SLEEPING);
        expect(event.state, State.SLEEPING);
      },
    );

    test(
      'doAction does not change state on invalid transitions from OCCURRING',
      () {
        final media = Media(id: 'm1');
        final event = media.getMainEvent();
        event.doAction(ActionType.START);
        expect(event.state, State.OCCURRING);
        expect(event.doAction(ActionType.START), State.OCCURRING);
        expect(event.doAction(ActionType.RESUME), State.OCCURRING);
        expect(event.state, State.OCCURRING);
      },
    );

    test(
      'doAction does not change state on invalid transitions from PAUSED',
      () {
        final media = Media(id: 'm1');
        final event = media.getMainEvent();
        event.doAction(ActionType.START);
        event.doAction(ActionType.PAUSE);
        expect(event.state, State.PAUSED);
        expect(event.doAction(ActionType.START), State.PAUSED);
        expect(event.doAction(ActionType.PAUSE), State.PAUSED);
        expect(event.state, State.PAUSED);
      },
    );

    test('doAction ABORT behaves like STOP from OCCURRING and PAUSED', () {
      final media = Media(id: 'm1');
      final event = media.getMainEvent();
      event.doAction(ActionType.START);
      expect(event.doAction(ActionType.ABORT), State.SLEEPING);

      event.doAction(ActionType.START);
      event.doAction(ActionType.PAUSE);
      expect(event.doAction(ActionType.ABORT), State.SLEEPING);
    });

    test('Event helper methods work correctly', () {
      expect(Event.getStringAsActionType('start'), ActionType.START);
      expect(Event.getStringAsActionType('stop'), ActionType.STOP);
      expect(Event.getEventStateAsString(State.OCCURRING), 'occurring');
      expect(
        Event.getEventTypeAsString(EventType.PRESENTATION),
        'presentation',
      );
    });

    test('Media Initialization', () {
      final media = Media(
        id: 'm1',
        rawAttributes: {'id': 'm1', 'src': 'video.mp4', 'type': 'video/mp4'},
      );
      expect(media.id, 'm1');
      expect(media.rawAttributes['src'], 'video.mp4');
      expect(media.rawAttributes['type'], 'video/mp4');
    });

    test('Settings Initialization', () {
      final settings = Settings(id: 's1', rawAttributes: {'id': 's1'});
      expect(settings, isA<Settings>());
      expect(settings.id, 's1');
    });
  });
}
