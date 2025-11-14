import 'package:flutter_test/flutter_test.dart';
import 'package:gingaf/ncl/ncl_doc.dart';

void main() {
  group('NCL Document Data Structures', () {
    test('NCLMedia Initialization', () {
      final media = NCLMedia(id: 'm1', src: 'video.mp4', type: 'video/mp4');
      expect(media.id, 'm1');
      expect(media.src, 'video.mp4');
      expect(media.type, 'video/mp4');
    });

    test('NCLPort Initialization', () {
      final port = NCLPort(id: 'p1', component: 'm1', interface: 'i1');
      expect(port.id, 'p1');
      expect(port.component, 'm1');
      expect(port.interface, 'i1');
    });

    test('NCLDocument Composition', () {
      final media = NCLMedia(id: 'm1', src: 'v.mp4');
      final port = NCLPort(id: 'p1', component: 'm1');
      final doc = NCLDocument(
        mediaList: [media],
        portList: [port],
      );

      expect(doc.mediaList.length, 1);
      expect(doc.portList.length, 1);
      expect(doc.mediaList.first.id, 'm1');
      expect(doc.portList.first.id, 'p1');
    });
  });
}
