import 'package:ncl_doc/ncl_document.dart';
import 'package:test/test.dart';

void main() {
  group('NCLDocument Media Only Tests', () {
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
      doc.start();
      expect(doc.getBodyState(), State.OCCURRING);
      expect(doc.virtualClock, 0);
      expect(doc.getNodeById('m1')?.getMainState(), State.OCCURRING);
      doc.stop();
      expect(doc.getBodyState(), State.SLEEPING);
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
      doc.start();
      doc.tick(10);
      expect(doc.getNodeById('video1')?.getMainState(), State.SLEEPING);
      doc.stop();
      expect(doc.getNodeById('video1')?.getMainState(), State.SLEEPING);
      expect(doc.getNodeById('audio1')?.getMainState(), State.SLEEPING);
      expect(doc.getBodyState(), State.SLEEPING);
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
      doc.start();
      expect(doc.getBodyState(), State.OCCURRING);
      expect(doc.getNodeById('ginga_logo')?.getMainState(), State.OCCURRING);
      doc.stop();
      expect(doc.getNodeById('ginga_logo')?.getMainState(), State.SLEEPING);
      expect(doc.getBodyState(), State.SLEEPING);
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
      doc.start();
      expect(doc.getBodyState(), State.OCCURRING);
      expect(doc.getNodeById('lua_script')?.getMainState(), State.SLEEPING);
      doc.stop();
      expect(doc.getNodeById('lua_script')?.getMainState(), State.SLEEPING);
      expect(doc.getBodyState(), State.SLEEPING);
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
      doc.start();
      expect(doc.virtualClock, 0);
      expect(doc.getNodeById('m1')?.getMainState(), State.OCCURRING);
      expect(doc.getBodyState(), State.OCCURRING);
      doc.tick(1);
      expect(doc.virtualClock, 1);
      doc.stop();
      expect(doc.getNodeById('m1')?.getMainState(), State.SLEEPING);
      expect(doc.getBodyState(), State.SLEEPING);
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
      doc.start();
      expect(doc.getBodyState(), State.OCCURRING);
      expect(doc.virtualClock, 0);
      expect(doc.getNodeById('m1')?.getMainState(), State.OCCURRING);
      doc.tick(1);
      expect(doc.virtualClock, 1);
      doc.stop();
      expect(doc.getNodeById('m1')?.getMainState(), State.SLEEPING);
      expect(doc.getBodyState(), State.SLEEPING);
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
      doc.start();
      expect(doc.getBodyState(), State.OCCURRING);
      expect(doc.virtualClock, 0);
      expect(doc.getNodeById('m1')?.getMainState(), State.OCCURRING);
      doc.tick(1);
      expect(doc.virtualClock, 1);
      doc.stop();
      expect(doc.getNodeById('m1')?.getMainState(), State.SLEEPING);
      expect(doc.getBodyState(), State.SLEEPING);
    });

    test('state of media with areas doc', () {
      const xmlString = '''
<ncl>
  <body>
    <media id="video_main" src="main.mp4">
      <area id="seg1" begin="10s" end="20s" />
    </media>
  </body>
</ncl>
''';
      final doc = NCLDocument.fromXML(xmlString);
      doc.start();
      expect(doc.getBodyState(), State.OCCURRING);
      expect(doc.getNodeById('video_main')?.getMainState(), State.SLEEPING);
      doc.stop();
      expect(doc.getNodeById('video_main')?.getMainState(), State.SLEEPING);
      expect(doc.getBodyState(), State.SLEEPING);
    });

    test('start media with area from port', () {
      const xml = '''
<ncl>
  <body>
    <port id="p1" component="video_main"/>
    <media id="video_main" src="main.mp4">
      <area id="seg1" begin="10s" end="20s" />
    </media>
  </body>
</ncl>
''';
      final doc = NCLDocument.fromXML(xml);
      doc.start();
      expect(doc.virtualClock, 0);
      expect(doc.getNodeById('video_main')?.getMainState(), State.OCCURRING);
      expect(doc.getBodyState(), State.OCCURRING);
      doc.tick(1);
      expect(doc.virtualClock, 1);
      doc.stop();
      expect(doc.getNodeById('video_main')?.getMainState(), State.SLEEPING);
      expect(doc.getBodyState(), State.SLEEPING);
    });
  });
}
