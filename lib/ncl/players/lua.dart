import 'package:flutter/material.dart';
import 'package:lua_dardo_plus/lua.dart';
import 'base.dart';

class LuaPlayer extends StatefulWidget {
  final String uri;
  const LuaPlayer({super.key, required this.uri});

  @override
  State<LuaPlayer> createState() => LuaPlayerState();
}

class LuaPlayerState extends PlayerState<LuaPlayer> {
  late LuaState _lua;
  final CanvasState canvasState = CanvasState();

  @override
  void initState() {
    super.initState();
    initPlayer(widget.uri);
    _initLuaEngine();
    _runScript();
  }

  void _initLuaEngine() {
    _lua = LuaState.newState();
    _lua.openLibs();
    
    _lua.register("_dart_attrColor", (LuaState ls) {
      final r = ls.toInteger(-4);
      final g = ls.toInteger(-3);
      final b = ls.toInteger(-2);
      final a = ls.toInteger(-1);
      canvasState.attrColor(r, g, b, a);
      return 0;
    });

    _lua.register("_dart_drawRect", (LuaState ls) {
      final mode = ls.toStr(-5) ?? "fill";
      final x = ls.toNumber(-4);
      final y = ls.toNumber(-3);
      final w = ls.toNumber(-2);
      final h = ls.toNumber(-1);
      canvasState.drawRect(mode, x, y, w, h);
      return 0;
    });
    
    try {
      _lua.doString(_ooWrapper);
    } catch (e) {
      debugPrint("Lua Wrapper Error: $e");
    }
    
    canvasState.onUpdate = () {
      if (mounted) setState(() {});
    };
  }

  Future<void> _runScript() async {
    canvasState.reset();
    try {
      final script = await loadContent(uri);
      _lua.doString(script);
    } catch (e) {
      debugPrint("Lua Runtime Error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: RepaintBoundary(
        child: CustomPaint(
          painter: _LuaPainter(canvasState.commands),
          size: Size.infinite,
        ),
      ),
    );
  }
}

class DrawCommand {
  final Rect rect;
  final Paint paint;
  DrawCommand(this.rect, this.paint);
}

class CanvasState {
  final List<DrawCommand> commands = [];
  Color currentColor = Colors.black;
  VoidCallback? onUpdate;

  void reset() {
    commands.clear();
    currentColor = Colors.black;
  }

  void attrColor(int r, int g, int b, int a) {
    currentColor = Color.fromARGB(a, r, g, b);
  }

  void drawRect(String mode, double x, double y, double w, double h) {
    final paint = Paint()..color = currentColor;
    if (mode == 'fill') {
      paint.style = PaintingStyle.fill;
    } else {
      paint.style = PaintingStyle.stroke;
      paint.strokeWidth = 2.0;
    }
    commands.add(DrawCommand(Rect.fromLTWH(x, y, w, h), paint));
    onUpdate?.call();
  }
}

class _LuaPainter extends CustomPainter {
  final List<DrawCommand> cmds;
  _LuaPainter(List<DrawCommand> original) : cmds = List.of(original);

  @override
  void paint(Canvas canvas, Size size) {
    if (cmds.isEmpty) return;
    for (var cmd in cmds) {
      canvas.drawRect(cmd.rect, cmd.paint);
    }
  }

  @override
  bool shouldRepaint(covariant _LuaPainter oldDelegate) => true;
}

const String _ooWrapper = '''
canvas = {}
canvas.__index = canvas

local color_names = {
  red = {255, 0, 0, 255},
  black = {0, 0, 0, 255},
  white = {255, 255, 255, 255},
  blue = {0, 0, 255, 255},
  green = {0, 255, 0, 255}
}

function canvas.new(...)
   return setmetatable({}, canvas)
end

function canvas:attrColor(...)
    local args = {...}
    if type(args[1]) == "string" then
        local c = color_names[args[1]]
        if c then
            _dart_attrColor(c[1], c[2], c[3], c[4])
        end
    elseif type(args[1]) == "number" then
        local r = args[1]
        local g = args[2]
        local b = args[3]
        local a = args[4] or 255
        _dart_attrColor(r, g, b, a)
    end
    return true
end

function canvas:drawRect(mode, x, y, w, h)
    _dart_drawRect(mode, x, y, w, h)
end
''';
