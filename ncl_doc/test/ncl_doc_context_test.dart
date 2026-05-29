import 'package:ncl_doc/ncl_document.dart';
import 'package:test/test.dart';

void main() {
  group('NCLDocument Context Tests', () {
    test('state of nested contexts doc', () {
      const xmlString = '''
        <ncl>
          <body>
            <context id="c1">
              <media id="m1" src="media.mp4" />
              <context id="c2">
                <media id="m2" src="video.mp4" />
              </context>
            </context>
          </body>
        </ncl>
        ''';
      final doc = NCLDocument.fromXML(xmlString);
      doc.start();
      doc.stop();
      expect(doc.getNodeById('c1')?.getNodeState(), State.SLEEPING);
      expect(doc.getNodeById('m1')?.getNodeState(), State.SLEEPING);
      expect(doc.getNodeById('m2')?.getNodeState(), State.SLEEPING);
      expect(doc.getBodyState(), State.SLEEPING);
    });

    test('start context from port', () {
      const xml = '''
<ncl>
  <body>
    <port id="p1" component="ctx1"/>
    <context id="ctx1">
      <media id="m1" src="v1.mp4" type="video/mp4"/>
    </context>
  </body>
</ncl>
''';
      final doc = NCLDocument.fromXML(xml);
      doc.start();
      expect(doc.getBodyState(), State.OCCURRING);
      expect(doc.virtualClock, 0);
      expect(doc.getNodeById('ctx1')?.getNodeState(), State.OCCURRING);
      doc.tick(1);
      expect(doc.virtualClock, 1);
      doc.stop();
      expect(doc.getNodeById('ctx1')?.getNodeState(), State.SLEEPING);
      expect(doc.getBodyState(), State.SLEEPING);
    });
  });
}
