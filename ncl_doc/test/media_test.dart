import 'package:ncl_doc/ncl_document.dart';
import 'package:test/test.dart';

void main() {
  group('Media Tests', () {
    test('Media can return its properties and areas', () {
      final media = Media(id: 'video1');
      final prop = Property(id: 'p1', rawAttributes: {'name': 'bounds', 'value': '0,0,100,100'});
      final area = Area(id: 'a1', rawAttributes: {'begin': '10s'});
      media.children.addAll([prop, area]);
      
      expect(media.getProperties().length, 1);
      expect(media.getProperties().first.name, 'bounds');
      expect(media.getProperties().first.value, '0,0,100,100');
      
      expect(media.getAreas().length, 1);
      expect(media.getAreas().first.begin, '10s');
    });

    test('lambda on Node returns same Event instance', () {
      final media = Media(id: 'm1');
      final event1 = media.lambda;
      final event2 = media.lambda;
      expect(event1, same(event2));
      expect(event1.targetNode.id, 'm1');
      expect(event1.type, EventType.PRESENTATION);
    });

    test('doAction transition logic', () {
      final media = Media(id: 'm1');
      final event = media.lambda;
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

    test('Port Initialization', () {
      final port = Port(
        id: 'p1',
        rawAttributes: {'id': 'p1', 'component': 'm1', 'interface': 'i1'},
      );
      expect(port.id, 'p1');
      expect(port.component, 'm1');
      expect(port.interface, 'i1');
    });

    test('Settings Initialization', () {
      final settings = Settings(id: 's1', rawAttributes: {'id': 's1'});
      expect(settings, isA<Settings>());
      expect(settings.id, 's1');
    });
  });
}
