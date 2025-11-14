import 'package:flutter_test/flutter_test.dart';
import 'package:gingaf/ncl/ncl_parser.dart';

void main() {
  group('NCLParser Tests', () {
    test('Should parse multiple entry ports and media correctly', () {
      const ncl = '''
<ncl>
  <body>
    <port id="init1" component="lua_media"/>
    <port id="init2" component="html_media"/>
    <media id="lua_media" src="main.lua" type="application/x-ginga-NCLua"/>
    <media id="html_media" src="index.html" type="text/html"/>
  </body>
</ncl>
''';
      final doc = NCLParser.parse(ncl);

      expect(doc.portList.length, equals(2));
      expect(doc.mediaList.length, equals(2));

      expect(doc.portList[0].id, equals('init1'));
      expect(doc.portList[0].component, equals('lua_media'));

      expect(doc.mediaList[0].id, equals('lua_media'));
      expect(doc.mediaList[0].src, equals('main.lua'));
      expect(doc.mediaList[1].src, equals('index.html'));
    });
  });
}
