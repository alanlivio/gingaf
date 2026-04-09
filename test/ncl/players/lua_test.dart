import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gingaf/ncl/ncl_player.dart';
import 'package:gingaf/ncl/players/lua.dart';

class MockAssetBundle extends CachingAssetBundle {
  final Map<String, String> assets;

  MockAssetBundle({required this.assets});

  @override
  Future<ByteData> load(String key) async {
    return ByteData(0);
  }

  @override
  Future<String> loadString(String key, {bool cache = true}) async {
    if (assets.containsKey(key)) {
      return assets[key]!;
    }
    throw FlutterError('MockAssetBundle: Unknown key $key');
  }
}

void main() {
  final sharedAssets = {
    'test.ncl': '''
<ncl>
  <body>
    <port id="init" component="lua_media"/>
    <media id="lua_media" src="test.lua" type="application/x-ginga-NCLua"/>
  </body>
</ncl>
''',
    'test.lua': '''
local c = canvas.new("test")
c:attrColor("red")
c:drawRect("fill", 0, 0, 50, 50)
c:attrColor("blue")
c:drawRect("frame", 60, 60, 40, 40)
c:attrColor(0, 255, 0, 255)
c:drawRect("fill", 110, 110, 20, 20)
''',
  };

  testWidgets('NCL Integration Mounting Verification',
      (WidgetTester tester) async {
    final mockBundle = MockAssetBundle(assets: sharedAssets);

    await tester.pumpWidget(
      MaterialApp(
        home: DefaultAssetBundle(
          bundle: mockBundle,
          child: const NCLPlayer(uri: 'test.ncl'),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.byType(NCLPlayer), findsOneWidget);
  });

  group('LuaPlayer Standalone Unit Tests', () {
    testWidgets('LuaPlayer should process multiple drawing commands',
        (WidgetTester tester) async {
      final mockBundle = MockAssetBundle(assets: sharedAssets);

      await tester.pumpWidget(
        MaterialApp(
          home: DefaultAssetBundle(
            bundle: mockBundle,
            child: const LuaPlayer(uri: 'test.lua'),
          ),
        ),
      );
      // Allow async loadContent and Lua execution to complete
      await tester.pumpAndSettle();

      final state = tester.state<LuaPlayerState>(find.byType(LuaPlayer));

      final commands = state.canvasState.commands;
      expect(commands.length, 3);
      expect(commands[0].paint.color, const Color(0xFFFF0000));
      expect(commands[1].paint.color, const Color(0xFF0000FF));
      expect(commands[2].paint.color, const Color(0xFF00FF00));
    });
  });
}
