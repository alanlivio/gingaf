import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gingaf/ginga.dart';
import 'package:gingaf/ncl/ncl_app.dart';

void main() {
  group('GingaConfig Logic Tests', () {
    test(
        'Constructor should accept .ncl and .html extensions case-insensitively',
        () {
      expect(GingaConfig('app.ncl').appPath, 'app.ncl');
      expect(GingaConfig('app.html').appPath, 'app.html');
      expect(GingaConfig('APP.NCL').appPath, 'APP.NCL');
      expect(GingaConfig('APP.HTML').appPath, 'APP.HTML');
    });

    test('Constructor should capture CCWS environment (true by default)', () {
      final config = GingaConfig('app.ncl');
      expect(config.enableCCWS, isTrue);
    });

    test('Constructor should support explicit CCWS deactivation', () {
      final config = GingaConfig('app.ncl', false);
      expect(config.enableCCWS, isFalse);
    });

    test(
        'Constructor should reject unsupported extensions and set appPath to null',
        () {
      expect(GingaConfig('app.txt').appPath, isNull);
      expect(GingaConfig('app.lua').appPath, isNull);
      expect(GingaConfig('app').appPath, isNull);
      expect(GingaConfig('').appPath, isNull);
    });
  });

  group('Widget Tests', () {
    testWidgets('NCLApp mounts example', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(
        home: NCLApp(uri: '../examples/video.ncl'),
      ));

      // Use pump() instead of pumpAndSettle() because the NCLApp uses an infinite periodic timer
      await tester.pump(const Duration(seconds: 1));

      // Assert that NCLApp is in the tree
      expect(find.byType(NCLApp), findsOneWidget);
    });
  });
}
