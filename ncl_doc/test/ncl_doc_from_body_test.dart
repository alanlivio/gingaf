import 'package:ncl_doc/ncl_document.dart';
import 'package:test/test.dart';

void main() {
  group('NCLDocument from nodes Tests', () {
    test('tick increments virtual clock', () {
      final doc = NCLDocument.fromBodyElements([]);
      expect(doc.virtualClock, 0);
      doc.start();
      doc.tick(10);
      expect(doc.virtualClock, 10);
      doc.tick(1);
      expect(doc.virtualClock, 11);
    });

    test('tick does not go backwards', () {
      final doc = NCLDocument.fromBodyElements([]);
      doc.start();
      doc.tick(100);
      expect(doc.virtualClock, 100);
      doc.tick(0);
      expect(doc.virtualClock, 100);
    });

    test('automatic start via Port', () {
      final media = Media(id: 'm1');
      final port = Port(id: 'p1', rawAttributes: {'component': 'm1'});
      final doc = NCLDocument.fromBodyElements([media, port]);
      doc.start();
      expect(doc.getBodyState(), State.OCCURRING);
      expect(doc.getNodeById('m1')?.getNodeState(), State.OCCURRING);
      doc.stop();
      expect(doc.getNodeById('m1')?.getNodeState(), State.SLEEPING);
      expect(doc.getBodyState(), State.SLEEPING);
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
      final doc = NCLDocument.fromBodyElements([m1, m2, port, link]);
      doc.start();
      expect(doc.getBodyState(), State.OCCURRING);
      expect(doc.getNodeById('m1')?.getNodeState(), State.OCCURRING);
      expect(doc.getNodeById('m2')?.getNodeState(), State.OCCURRING);
      doc.stop();
      expect(doc.getNodeById('m1')?.getNodeState(), State.SLEEPING);
      expect(doc.getNodeById('m2')?.getNodeState(), State.SLEEPING);
      expect(doc.getBodyState(), State.SLEEPING);
    });

    test('default Settings is created if none is provided', () {
      final doc = NCLDocument.fromBodyElements([]);
      final settings = doc.getSettings();
      expect(settings, isNotNull);
      expect(settings.id, '__settings__');
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
      final doc = NCLDocument.fromBodyElements([media, port]);

      // Expect 2 because Settings now extends Media and a default_settings is added
      expect(doc.getBody().getNodes().whereType<Media>().length, 2);
      expect(doc.getBody().getPorts().length, 1);
      expect(doc.getBody().getNodes().whereType<Media>().first.id, 'm1');
      expect(doc.getBody().getPorts().first.id, 'p1');
    });

    test('getSettings is returned correctly when provided', () {
      final settings = Settings(id: 's1');
      final doc = NCLDocument.fromBodyElements([settings]);
      expect(doc.getSettings(), settings);
    });
  });
}
