import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ncl_app/ncl_app.dart';

class MockExamplesAssetBundle extends CachingAssetBundle {
  final Map<String, String> files = {
    '00syncProp.ncl': '''
<ncl>
  <body>
    <port id="p1" component="m1"/>
    <media id="m1" src="v1.mp4" type="video/mp4">
      <property name="visible" value="true"/>
    </media>
  </body>
</ncl>
''',
    '01sync.ncl': '''
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
''',
    '02syncInt.ncl': '''
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
''',
    '03context.ncl': '''
<ncl>
  <body>
    <port id="p1" component="ctx1"/>
    <context id="ctx1">
      <media id="m1" src="v1.mp4" type="video/mp4"/>
    </context>
  </body>
</ncl>
''',
    '04reuse.ncl': '''
<ncl>
  <body>
    <port id="p1" component="m1"/>
    <media id="m1" src="v1.mp4" type="video/mp4"/>
  </body>
</ncl>
''',
    '05return.ncl': '''
<ncl>
  <body>
    <port id="p1" component="m1"/>
    <media id="m1" src="v1.mp4" type="video/mp4"/>
  </body>
</ncl>
''',
    '06switch.ncl': '''
<ncl>
  <body>
    <port id="p1" component="m1"/>
    <media id="m1" src="v1.mp4" type="video/mp4"/>
  </body>
</ncl>
''',
    '07transition.ncl': '''
<ncl>
  <body>
    <port id="p1" component="m1"/>
    <media id="m1" src="v1.mp4" type="video/mp4"/>
  </body>
</ncl>
''',
    '08animation.ncl': '''
<ncl>
  <body>
    <port id="p1" component="m1"/>
    <media id="m1" src="v1.mp4" type="video/mp4"/>
  </body>
</ncl>
''',
    '09settings.ncl': '''
<ncl>
  <body>
    <port id="p1" component="m1"/>
    <media id="m1" src="v1.mp4" type="video/mp4"/>
  </body>
</ncl>
''',
    '10menu.ncl': '''
<ncl>
  <body>
    <port id="p1" component="m1"/>
    <media id="m1" src="v1.mp4" type="video/mp4"/>
  </body>
</ncl>
''',
    '11nclua.ncl': '''
<ncl>
  <body>
    <port id="p1" component="m1"/>
    <media id="m1" src="script.lua" type="application/x-ginga-NCLua"/>
  </body>
</ncl>
''',
    '12embNCL.ncl': '''
<ncl>
  <body>
    <port id="p1" component="m1"/>
    <media id="m1" src="v1.mp4" type="video/mp4"/>
  </body>
</ncl>
''',
    'advert.ncl': '''
<ncl>
  <body>
    <port id="p1" component="m1"/>
    <media id="m1" src="v1.mp4" type="video/mp4"/>
  </body>
</ncl>
''',
    'causalConnBase.ncl': '''
<ncl>
  <body>
    <port id="p1" component="m1"/>
    <media id="m1" src="v1.mp4" type="video/mp4"/>
  </body>
</ncl>
''',
  };

  @override
  Future<ByteData> load(String key) async {
    return ByteData(0);
  }

  @override
  Future<String> loadString(String key, {bool cache = true}) async {
    if (files.containsKey(key)) {
      return files[key]!;
    }
    throw FlutterError('Unknown key: $key');
  }
}

void main() {
  final bundle = MockExamplesAssetBundle();

  void defineExampleTest(String filename) {
    testWidgets('Verify execution of $filename', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Material(
            child: DefaultAssetBundle(
              bundle: bundle,
              child: NCLApp(uri: filename),
            ),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 500));
      expect(find.byType(NCLApp), findsOneWidget);
    });
  }

  group('TeleMidia primeiro-joao Examples Execution Tests', () {
    defineExampleTest('00syncProp.ncl');
    defineExampleTest('01sync.ncl');
    defineExampleTest('02syncInt.ncl');
    defineExampleTest('03context.ncl');
    defineExampleTest('04reuse.ncl');
    defineExampleTest('05return.ncl');
    defineExampleTest('06switch.ncl');
    defineExampleTest('07transition.ncl');
    defineExampleTest('08animation.ncl');
    defineExampleTest('09settings.ncl');
    defineExampleTest('10menu.ncl');
    defineExampleTest('11nclua.ncl');
    defineExampleTest('12embNCL.ncl');
    defineExampleTest('advert.ncl');
    defineExampleTest('causalConnBase.ncl');
  });
}
