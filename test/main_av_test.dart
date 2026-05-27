import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gingaf/main.dart';
import 'package:gingaf/html_app.dart';
import 'package:ncl_app/ncl_app.dart';

class MockAVAssetBundle extends CachingAssetBundle {
  final Map<String, String> assets;

  MockAVAssetBundle({required this.assets});

  @override
  Future<ByteData> load(String key) async {
    return ByteData(0);
  }

  @override
  Future<String> loadString(String key, {bool cache = true}) async {
    if (assets.containsKey(key)) {
      return assets[key]!;
    }
    throw FlutterError('MockAVAssetBundle: Unknown key $key');
  }
}

void main() {
  testWidgets('MainAVController and MainAVWidget rendering', (WidgetTester tester) async {
    final controller = MainAVController()..setVideoUri('background.mp4');

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: MainAVWidget(controller: controller),
        ),
      ),
    );

    expect(find.text('Playing Background AV: background.mp4'), findsOneWidget);

    controller.stop();
    await tester.pump();
    expect(find.text('Playing Background AV: background.mp4'), findsNothing);

    controller.play();
    await tester.pump();
    expect(find.text('Playing Background AV: background.mp4'), findsOneWidget);
  });

  test('HTMLApp can change background video via callback', () {
    String? changedUri;
    final app = HTMLApp(
      uri: 'test.html',
      onBackgroundVideoChanged: (uri) {
        changedUri = uri;
      },
    );

    app.onBackgroundVideoChanged?.call('html_bg.mp4');
    expect(changedUri, 'html_bg.mp4');
  });

  testWidgets('NCLApp can change background video via settings property', (WidgetTester tester) async {
    String? changedUri;
    const nclData = '''
<ncl>
  <body>
    <port id="p1" component="m1"/>
    <media id="m1" src="v1.mp4" type="video/mp4"/>
    <settings id="s1">
      <property name="videoUri" value="ncl_bg.mp4"/>
    </settings>
  </body>
</ncl>
''';

    final mockBundle = MockAVAssetBundle(assets: {
      'test_bg.ncl': nclData,
    });

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: DefaultAssetBundle(
            bundle: mockBundle,
            child: NCLApp(
              uri: 'test_bg.ncl',
              onBackgroundVideoChanged: (uri) {
                changedUri = uri;
              },
            ),
          ),
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 500));

    expect(changedUri, 'ncl_bg.mp4');
  });
}
