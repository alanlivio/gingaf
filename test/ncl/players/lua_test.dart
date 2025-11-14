import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gingaf/ncl/ncl_app.dart';
import 'package:gingaf/ncl/players/lua.dart';

class MockAssetBundle extends CachingAssetBundle {
  @override
  Future<ByteData> load(String key) async {
    return ByteData(0);
  }

  @override
  Future<String> loadString(String key, {bool cache = true}) async {
    if (key == 'test.ncl') {
      return '''
<ncl>
  <body>
    <port id="init" component="lua_media"/>
    <media id="lua_media" src="test.lua" type="application/x-ginga-NCLua"/>
  </body>
</ncl>
''';
    }
    if (key == 'test.lua') {
      return 'local c = canvas.new("test")\nc:attrColor("red")\nc:drawRect("fill", 10, 10, 100, 100)';
    }
    throw FlutterError('MockAssetBundle: Unknown key $key');
  }
}

void main() {
  testWidgets('NCL Integration Mounting Verification',
      (WidgetTester tester) async {
    final mockBundle = MockAssetBundle();

    await tester.pumpWidget(
      MaterialApp(
        home: DefaultAssetBundle(
          bundle: mockBundle,
          child: const NCLApp(uri: 'test.ncl'),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.byType(NCLApp), findsOneWidget);
  });

  group('LuaPlayer Standalone Unit Tests', () {
    test('LuaPlayer should process multiple drawing commands', () async {
      const luaContent = '''
local c = canvas.new("test")
c:attrColor("red")
c:drawRect("fill", 0, 0, 50, 50)
c:attrColor("blue")
c:drawRect("frame", 60, 60, 40, 40)
c:attrColor(0, 255, 0, 255)
c:drawRect("fill", 110, 110, 20, 20)
''';
      final player = LuaPlayer();
      player.init(luaContent);
      await player.start();

      final commands = player.canvasState.commands;
      expect(commands.length, 3);

      expect(commands[0].paint.color, const Color(0xFFFF0000));
      expect(commands[0].paint.style, PaintingStyle.fill);
      expect(commands[0].rect, const Rect.fromLTWH(0, 0, 50, 50));

      expect(commands[1].paint.color, const Color(0xFF0000FF));
      expect(commands[1].paint.style, PaintingStyle.stroke);
      expect(commands[1].rect, const Rect.fromLTWH(60, 60, 40, 40));

      expect(commands[2].paint.color, const Color(0xFF00FF00));
      expect(commands[2].paint.style, PaintingStyle.fill);
      expect(commands[2].rect, const Rect.fromLTWH(110, 110, 20, 20));
    });

    test('LuaPlayer should bridge RGBA values correctly', () async {
      const luaContent =
          'local c = canvas.new(); c:attrColor(10, 20, 30, 40); c:drawRect("fill", 0, 0, 1, 1)';
      final player = LuaPlayer();
      player.init(luaContent);
      await player.start();

      expect(player.canvasState.commands.length, 1);
      final color = player.canvasState.commands.first.paint.color;
      expect(color.alpha, 40);
      expect(color.red, 10);
      expect(color.green, 20);
      expect(color.blue, 30);
    });
  });
}
