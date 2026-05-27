import 'package:ncl_doc/ncl_document.dart';
import 'package:test/test.dart';

void main() {
  group('NCLParser Tests', () {
    late NCLParser parser;

    setUp(() {
      parser = NCLParser();
    });

    test('parseString parses all NCL node types successfully', () {
      const xmlString = '''
      <ncl id="ncl_doc">
        <head>
          <regionBase>
            <region id="reg1" />
          </regionBase>
          <descriptorBase>
            <descriptor id="desc1" />
          </descriptorBase>
          <connectorBase>
            <causalConnector id="conn1">
              <connector id="conn2" />
            </causalConnector>
          </connectorBase>
          <settings id="s1">
            <property id="prop1" name="service.currentKey" value="1" />
          </settings>
        </head>
        <body>
          <port id="p1" component="c1" />
          <context id="c1">
            <media id="m1" src="video.mp4">
              <area id="area1" begin="10s" />
              <property id="prop2" name="fontColor" value="blue" />
            </media>
          </context>
          <link id="l1">
            <bind role="onBegin" component="m1" />
          </link>
        </body>
      </ncl>
      ''';

      final document = parser.parseString(xmlString);
      final elements = document.elements;

      final ncl = elements.firstWhere((e) => e.id == 'ncl_doc');
      expect(ncl, isA<NCLXMLElement>());

      final region = elements.firstWhere((e) => e.id == 'reg1');
      expect(region, isA<Region>());

      final descriptor = elements.firstWhere((e) => e.id == 'desc1');
      expect(descriptor, isA<Descriptor>());

      final conn1 = elements.firstWhere((e) => e.id == 'conn1');
      expect(conn1, isA<Connector>());
      final conn2 = elements.firstWhere((e) => e.id == 'conn2');
      expect(conn2, isA<Connector>());

      final settings = elements.firstWhere((e) => e.id == 's1');
      expect(settings, isA<Settings>());

      final prop1 = elements.firstWhere((e) => e.id == 'prop1') as Property;
      expect(prop1, isA<Property>());
      expect(prop1.name, 'service.currentKey');
      expect(prop1.value, '1');

      final prop2 = elements.firstWhere((e) => e.id == 'prop2') as Property;
      expect(prop2, isA<Property>());
      expect(prop2.name, 'fontColor');
      expect(prop2.value, 'blue');

      final port = elements.firstWhere((e) => e.id == 'p1') as Port;
      expect(port, isA<Port>());
      expect(port.component, 'c1');

      final context = elements.firstWhere((e) => e.id == 'c1');
      expect(context, isA<Context>());

      final media = elements.firstWhere((e) => e.id == 'm1');
      expect(media, isA<Media>());

      final area = elements.firstWhere((e) => e.id == 'area1') as Area;
      expect(area, isA<Area>());
      expect(area.begin, '10s');

      final link = elements.firstWhere((e) => e.id == 'l1');
      expect(link, isA<Link>());

      final bind = elements.firstWhere((e) => e.id == 'bind_onBegin') as Bind;
      expect(bind, isA<Bind>());
      expect(bind.role, 'onBegin');
      expect(bind.component, 'm1');
    });

    test('validate catches missing required attributes', () {
      final xmlString = '''
      <?xml version="1.0" encoding="UTF-8"?>
      <ncl>
        <body>
          <media src="video.mp4" />
        </body>
      </ncl>
      ''';

      final errors = parser.validate(xmlString);
      expect(errors.isNotEmpty, true);
      expect(
        errors.any(
          (e) =>
              e.contains('Missing required attribute "id" for element <media>'),
        ),
        true,
      );
    });

    test('validate catches unknown attributes', () {
      final xmlString = '''
      <?xml version="1.0" encoding="UTF-8"?>
      <ncl>
        <body>
          <media id="video1" src="video.mp4" unknown="123" />
        </body>
      </ncl>
      ''';

      final errors = parser.validate(xmlString);
      expect(errors.isNotEmpty, true);
      expect(
        errors.any(
          (e) => e.contains('Unknown attribute "unknown" for element <media>'),
        ),
        true,
      );
    });

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
      final doc = parser.parseString(ncl);
      final ports = doc.elements.whereType<Port>().toList();
      final mediaList = doc.elements.whereType<Media>().toList();

      expect(ports.length, equals(2));
      expect(mediaList.length, equals(2));

      expect(ports[0].id, equals('init1'));
      expect(ports[0].component, equals('lua_media'));

      expect(mediaList[0].id, equals('lua_media'));
      expect(mediaList[0].rawAttributes['src'], equals('main.lua'));
      expect(mediaList[1].rawAttributes['src'], equals('index.html'));
    });
  });
}
