import 'package:ncl_doc/ncl_document.dart';
import 'package:test/test.dart';

void main() {
  group('NCLDocument Tests', () {
    test('NCLDocument initializes and starts ticking', () async {
      const xml = r'''
<ncl>
  <body>
    <port id="p1" component="m1"/>
    <media id="m1" src="media.mp4"/>
  </body>
</ncl>
''';
      final doc = NCLDocument.fromXML(xml);
      expect(doc.getLambdaState('m1'), State.SLEEPING);
      doc.start(ticksPerSecond: 100);
      await Future.delayed(const Duration(milliseconds: 50));
      expect(doc.getBodyLambdaState(), State.OCCURRING);
      expect(doc.virtualClock, greaterThan(0));
      expect(doc.getLambdaState('m1'), State.OCCURRING);
      doc.stop();
      expect(doc.getBodyLambdaState(), State.SLEEPING);
    });

    test('state of media elements doc', () {
      const xmlString = '''
        <?xml version="1.0" encoding="UTF-8"?>
        <ncl>
          <body>
            <media id="video1" src="video.mp4" descriptor="desc1" />
            <media id="audio1" src="audio.mp3" descriptor="desc2" />
          </body>
        </ncl>
        ''';
      final doc = NCLDocument.fromXML(xmlString);

      expect(doc.getLambdaState('video1'), State.SLEEPING);
      expect(doc.getLambdaState('audio1'), State.SLEEPING);
      doc.tickTo(10);
      expect(doc.getLambdaState('video1'), State.SLEEPING);
      doc.stop();
      expect(doc.getLambdaState('video1'), State.SLEEPING);
      expect(doc.getLambdaState('audio1'), State.SLEEPING);
      expect(doc.getBodyLambdaState(), State.SLEEPING);
    });

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

      expect(doc.getLambdaState('c1'), State.SLEEPING);
      expect(doc.getLambdaState('m1'), State.SLEEPING);
      expect(doc.getLambdaState('m2'), State.SLEEPING);
      doc.stop();
      expect(doc.getLambdaState('c1'), State.SLEEPING);
      expect(doc.getLambdaState('m1'), State.SLEEPING);
      expect(doc.getLambdaState('m2'), State.SLEEPING);
      expect(doc.getBodyLambdaState(), State.SLEEPING);
    });

    test('state of image.ncl', () {
      const String imageNcl = r'''
        <ncl>
          <body>
            <port id="init" component="ginga_logo"/>
            <media id="ginga_logo" src="https://upload.wikimedia.org/wikipedia/commons/c/ce/Ginga_Middleware_Logo.png" type="image/png"/>
          </body>
        </ncl>
        ''';
      final doc = NCLDocument.fromXML(imageNcl);

      expect(doc.getLambdaState('ginga_logo'), State.SLEEPING);
      doc.tickTo(0);
      expect(doc.getBodyLambdaState(), State.OCCURRING);
      expect(doc.getLambdaState('ginga_logo'), State.OCCURRING);
      doc.stop();
      expect(doc.getLambdaState('ginga_logo'), State.SLEEPING);
      expect(doc.getBodyLambdaState(), State.SLEEPING);
    });

    test('state of media with properties doc', () {
      const xmlString = '''
        <ncl>
          <body>
            <media id="lua_script" src="main.lua">
              <property name="fontColor" value="blue" />
            </media>
          </body>
        </ncl>
        ''';
      final doc = NCLDocument.fromXML(xmlString);
      expect(doc.getLambdaState('lua_script'), State.SLEEPING);
      doc.stop();
      expect(doc.getLambdaState('lua_script'), State.SLEEPING);
      expect(doc.getBodyLambdaState(), State.SLEEPING);
    });

    test('start media with property from port', () {
      const xml = '''
<ncl>
  <body>
    <port id="p1" component="m1"/>
    <media id="m1" src="v1.mp4" type="video/mp4">
      <property name="visible" value="true"/>
    </media>
  </body>
</ncl>
''';
      final doc = NCLDocument.fromXML(xml);
      expect(doc.virtualClock, 0);
      expect(doc.getLambdaState('m1'), State.SLEEPING);

      doc.tickTo(0);
      expect(doc.virtualClock, 0);
      expect(doc.getLambdaState('m1'), State.OCCURRING);
      expect(doc.getBodyLambdaState(), State.OCCURRING);

      doc.tickTo(1);
      expect(doc.virtualClock, 1);
      doc.stop();
      expect(doc.getLambdaState('m1'), State.SLEEPING);
      expect(doc.getBodyLambdaState(), State.SLEEPING);
    });

    test('link onEnd starts another media', () {
      const xml = '''
<ncl>
  <body>
    <port id="p1" component="m1"/>
    <media id="m1" src="v1.mp4" type="video/mp4"/>
    <media id="m2" src="v2.mp4" type="video/mp4"/>
    <link id="l1">
      <bind role="onEnd" component="m1"/>
      <bind role="start" component="m2"/>
    </link>
  </body>
</ncl>
''';
      final doc = NCLDocument.fromXML(xml);
      expect(doc.virtualClock, 0);
      expect(doc.getLambdaState('m1'), State.SLEEPING);

      doc.tickTo(0);
      expect(doc.getBodyLambdaState(), State.OCCURRING);
      expect(doc.virtualClock, 0);
      expect(doc.getLambdaState('m1'), State.OCCURRING);

      doc.tickTo(1);
      expect(doc.virtualClock, 1);
      doc.stop();
      expect(doc.getLambdaState('m1'), State.SLEEPING);
      expect(doc.getBodyLambdaState(), State.SLEEPING);
    });

    test('link onBegin starts another media', () {
      const xml = '''
<ncl>
  <body>
    <port id="p1" component="m1"/>
    <media id="m1" src="v1.mp4" type="video/mp4"/>
    <media id="m2" src="v2.mp4" type="video/mp4"/>
    <link id="l1">
      <bind role="onBegin" component="m1"/>
      <bind role="start" component="m2"/>
    </link>
  </body>
</ncl>
''';
      final doc = NCLDocument.fromXML(xml);
      expect(doc.virtualClock, 0);
      expect(doc.getLambdaState('m1'), State.SLEEPING);

      doc.tickTo(0);
      expect(doc.getBodyLambdaState(), State.OCCURRING);
      expect(doc.virtualClock, 0);
      expect(doc.getLambdaState('m1'), State.OCCURRING);
      expect(doc.getLambdaState('m2'), State.OCCURRING);

      doc.tickTo(1);
      expect(doc.virtualClock, 1);
      doc.stop();
      expect(doc.getLambdaState('m1'), State.SLEEPING);
      expect(doc.getLambdaState('m2'), State.SLEEPING);
      expect(doc.getBodyLambdaState(), State.SLEEPING);
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
      expect(doc.virtualClock, 0);
      expect(doc.getLambdaState('ctx1'), State.SLEEPING);

      doc.tickTo(0);
      expect(doc.getBodyLambdaState(), State.OCCURRING);
      expect(doc.virtualClock, 0);
      expect(doc.getLambdaState('ctx1'), State.OCCURRING);

      doc.tickTo(1);
      expect(doc.virtualClock, 1);
      doc.stop();
      expect(doc.getLambdaState('ctx1'), State.SLEEPING);
      expect(doc.getBodyLambdaState(), State.SLEEPING);
    });

    test('start single media from port', () {
      const xml = '''
<ncl>
  <body>
    <port id="p1" component="m1"/>
    <media id="m1" src="v1.mp4" type="video/mp4"/>
  </body>
</ncl>
''';
      final doc = NCLDocument.fromXML(xml);
      expect(doc.virtualClock, 0);
      expect(doc.getLambdaState('m1'), State.SLEEPING);

      doc.tickTo(0);
      expect(doc.getBodyLambdaState(), State.OCCURRING);
      expect(doc.virtualClock, 0);
      expect(doc.getLambdaState('m1'), State.OCCURRING);

      doc.tickTo(1);
      expect(doc.virtualClock, 1);
      doc.stop();
      expect(doc.getLambdaState('m1'), State.SLEEPING);
      expect(doc.getBodyLambdaState(), State.SLEEPING);
    });

    test('start NCLua media', () {
      const xml = '''
<ncl>
  <body>
    <port id="p1" component="m1"/>
    <media id="m1" src="script.lua" type="application/x-ginga-NCLua"/>
  </body>
</ncl>
''';
      final doc = NCLDocument.fromXML(xml);
      expect(doc.virtualClock, 0);
      expect(doc.getLambdaState('m1'), State.SLEEPING);

      doc.tickTo(0);
      expect(doc.getBodyLambdaState(), State.OCCURRING);
      expect(doc.virtualClock, 0);
      expect(doc.getLambdaState('m1'), State.OCCURRING);

      doc.tickTo(1);
      expect(doc.virtualClock, 1);
      doc.stop();
      expect(doc.getLambdaState('m1'), State.SLEEPING);
      expect(doc.getBodyLambdaState(), State.SLEEPING);
    });
  });
}
