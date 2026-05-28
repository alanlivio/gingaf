import 'package:ncl_doc/ncl_document.dart';
import 'package:test/test.dart';

void main() {
  group('Media Tests', () {
    test('Node properties can be observed', () {
      final media = Media(id: 'video1');
      bool listenerFired = false;
      dynamic updatedValue;
      media.addPropertyChangeListener((name, value) {
        if (name == 'bounds') {
          listenerFired = true;
          updatedValue = value;
        }
      });
      media.setProperty('bounds', '0,0,100,100');
      expect(listenerFired, isTrue);
      expect(updatedValue, '0,0,100,100');
      expect(media.getProperty('bounds'), '0,0,100,100');
    });

    test('tick increments virtual clock', () {
      final vm = NCLDocument.fromElements();
      expect(vm.virtualClock, 0);
      vm.tick(10);
      expect(vm.virtualClock, 10);
      vm.tick();
      expect(vm.virtualClock, 11);
    });

    test('tickTo advances clock to specific time', () {
      final vm = NCLDocument.fromElements();
      vm.tickTo(100);
      expect(vm.virtualClock, 100);
      vm.tickTo(50);
      expect(vm.virtualClock, 100);
    });

    test('automatic start via Port', () {
      final media = Media(id: 'm1');
      final port = Port(id: 'p1', rawAttributes: {'component': 'm1'});
      final vm = NCLDocument.fromElements([media, port]);
      expect(vm.getLambdaState('m1'), State.SLEEPING);
      vm.tickTo(0);
      expect(vm.getLambdaState('m1'), State.OCCURRING);
    });

    test('causal link between two media', () {
      final m1 = Media(id: 'm1');
      final m2 = Media(id: 'm2');
      final port = Port(id: 'p1', rawAttributes: {'component': 'm1'});
      final link = Link(id: 'l1');
      link.children.add(
        Bind(rawAttributes: {'role': 'onBegin', 'component': 'm1'}),
      );
      link.children.add(
        Bind(rawAttributes: {'role': 'start', 'component': 'm2'}),
      );
      final vm = NCLDocument.fromElements([m1, m2, port, link]);
      vm.tickTo(0);
      expect(vm.getLambdaState('m1'), State.OCCURRING);
      expect(vm.getLambdaState('m2'), State.OCCURRING);
    });

    test('default Settings is created if none is provided', () {
      final doc = NCLDocument.fromElements();
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

    test('NCLDocument Composition', () {
      final media = Media(
        id: 'm1',
        rawAttributes: {'id': 'm1', 'src': 'v.mp4'},
      );
      final port = Port(
        id: 'p1',
        rawAttributes: {'id': 'p1', 'component': 'm1'},
      );
      final doc = NCLDocument.fromElements([media, port]);

      expect(doc.elements.whereType<Media>().length, 1);
      expect(doc.elements.whereType<Port>().length, 1);
      expect(doc.elements.whereType<Media>().first.id, 'm1');
      expect(doc.elements.whereType<Port>().first.id, 'p1');
    });

    test('Settings Initialization', () {
      final settings = Settings(id: 's1', rawAttributes: {'id': 's1'});
      expect(settings, isA<Settings>());
      expect(settings.id, 's1');
    });

    test('getSettings is returned correctly when provided', () {
      final settings = Settings(id: 's1');
      final doc = NCLDocument.fromElements([settings]);
      expect(doc.getSettings(), settings);
    });
  });
}
