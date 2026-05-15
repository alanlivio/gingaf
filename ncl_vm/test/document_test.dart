import 'package:ncl_vm/ncl_vm.dart';
import 'package:test/test.dart';

void main() {
  group('Document and Event State Tests', () {
    test('node types creations (Context, Media, Settings)', () {
      final context = Context(id: 'c1', rawAttributes: {'id': 'c1'});
      final media = Media(
        id: 'm1',
        rawAttributes: {'id': 'm1', 'src': 'video.mp4'},
      );
      final settings = Settings(id: 's1', rawAttributes: {'id': 's1'});

      expect(context, isA<Context>());
      expect(context.id, 'c1');

      expect(media, isA<Media>());
      expect(media.id, 'm1');
      expect(media.rawAttributes['src'], 'video.mp4');

      expect(settings, isA<Settings>());
      expect(settings.id, 's1');
    });

    test('getRoot and getSettings are returned correctly when provided', () {
      final root = Context(id: 'c1');
      final settings = Settings(id: 's1');
      final doc = Document([root, settings]);
      expect(doc.getRoot(), root);
      expect(doc.getSettings(), settings);
    });

    test('default Settings is created if none is provided', () {
      final doc = Document();
      final settings = doc.getSettings();
      expect(settings, isNotNull);
      expect(settings!.id, 'default_settings');
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

    test('Document Composition', () {
      final media = Media(
        id: 'm1',
        rawAttributes: {'id': 'm1', 'src': 'v.mp4'},
      );
      final port = Port(
        id: 'p1',
        rawAttributes: {'id': 'p1', 'component': 'm1'},
      );
      final doc = Document([media, port]);

      expect(doc.elements.whereType<Media>().length, 1);
      expect(doc.elements.whereType<Port>().length, 1);
      expect(doc.elements.whereType<Media>().first.id, 'm1');
      expect(doc.elements.whereType<Port>().first.id, 'p1');
    });
  });
}
