import 'package:ncl_doc/ncl_document.dart';
import 'package:test/test.dart';

void main() {
  group('NCLDocument Context With Links Tests', () {
    test('link onEnd starts another context', () {
      const xml = '''
<ncl>
  <body>
    <port id="p1" component="ctx1"/>
    <context id="ctx1">
      <media id="m1" src="v1.mp4" type="video/mp4"/>
    </context>
    <context id="ctx2">
      <media id="m2" src="v2.mp4" type="video/mp4"/>
    </context>
    <link id="l1">
      <bind role="onEnd" component="ctx1"/>
      <bind role="start" component="ctx2"/>
    </link>
  </body>
</ncl>
''';
      final doc = NCLDocument.fromXML(xml);
      doc.start();
      expect(doc.getBodyState(), State.OCCURRING);
      expect(doc.virtualClock, 0);
      expect(doc.getNodeById('ctx1')?.getNodeState(), State.OCCURRING);
      expect(doc.getNodeById('ctx2')?.getNodeState(), State.SLEEPING);
      doc.tick(1);
      expect(doc.virtualClock, 1);
      doc.stop();
      expect(doc.getNodeById('ctx1')?.getNodeState(), State.SLEEPING);
      expect(doc.getNodeById('ctx2')?.getNodeState(), State.SLEEPING);
      expect(doc.getBodyState(), State.SLEEPING);
    });

    test('trigger links only within target Context', () {
      const xml = '''
<ncl>
  <body>
    <port id="p1" component="c1"/>
    <port id="p2" component="c2"/>
    <context id="c1">
      <port id="p_c1" component="m1"/>
      <media id="m1" src="m1.mp4"/>
      <media id="m2" src="m2.mp4"/>
      <link id="l1">
        <bind role="onBegin" component="m1"/>
        <bind role="start" component="m2"/>
      </link>
    </context>
    <context id="c2">
      <port id="p_c2" component="m3"/>
      <media id="m3" src="m3.mp4"/>
      <media id="m4" src="m4.mp4"/>
      <link id="l2">
        <bind role="onBegin" component="m3"/>
        <bind role="start" component="m4"/>
      </link>
    </context>
  </body>
</ncl>
''';
      final doc = NCLDocument.fromXML(xml);
      doc.start();
      expect(doc.getNodeById('c1')?.getNodeState(), State.OCCURRING);
      expect(doc.getNodeById('c2')?.getNodeState(), State.OCCURRING);
      expect(doc.getNodeById('m1')?.getNodeState(), State.OCCURRING);
      expect(doc.getNodeById('m2')?.getNodeState(), State.OCCURRING);
      expect(doc.getNodeById('m3')?.getNodeState(), State.OCCURRING);
      expect(doc.getNodeById('m4')?.getNodeState(), State.OCCURRING);
    });
  });
}
