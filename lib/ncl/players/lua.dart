import 'package:flutter/material.dart';
import 'package:lua_dardo_plus/lua.dart';
import 'abstract.dart';

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

class GlobalCanvasPainter extends CustomPainter {
  final List<DrawCommand> cmds;
  GlobalCanvasPainter(List<DrawCommand> original) : cmds = List.of(original);

  @override
  void paint(Canvas canvas, Size size) {
    for (var cmd in cmds) {
      canvas.drawRect(cmd.rect, cmd.paint);
    }
  }

  @override
  bool shouldRepaint(covariant GlobalCanvasPainter oldDelegate) => true;
}

class LuaPlayer with Player {
  static List<String> get handledMimeTypes => ['application/x-ginga-NCLua'];
  
  late LuaState _state;
  final CanvasState canvasState = CanvasState();
  String? _content;

  @override
  void init(String uri) {
    this.uri = uri;
    _content = uri;
    _state = LuaState.newState();
    _state.openLibs();
    
    _state.register("_dart_attrColor", (LuaState ls) {
      final r = ls.toInteger(-4);
      final g = ls.toInteger(-3);
      final b = ls.toInteger(-2);
      final a = ls.toInteger(-1);
      canvasState.attrColor(r, g, b, a);
      return 0;
    });

    _state.register("_dart_drawRect", (LuaState ls) {
      final mode = ls.toStr(-5) ?? "fill";
      final x = ls.toNumber(-4);
      final y = ls.toNumber(-3);
      final w = ls.toNumber(-2);
      final h = ls.toNumber(-1);
      canvasState.drawRect(mode, x, y, w, h);
      return 0;
    });
    
    try {
      _state.doString(ooWrapper);
    } catch (e) {
      print("Lua Wrapper Error: $e");
    }
  }

  @override
  Future<void> start() async {
    if (_content != null) {
       canvasState.reset();
       try {
         _state.doString(_content!);
       } catch (e) {
         print("Lua Runtime Error: $e");
       }
    }
    state = PlayerState.occurring;
  }

  @override
  Future<void> stop() async {
    state = PlayerState.sleeping;
    canvasState.reset();
  }

  @override
  Future<void> pause() async {
    state = PlayerState.paused;
  }

  @override
  Future<void> resume() async {
    state = PlayerState.occurring;
  }

  @override
  Widget build(BuildContext context) {
    return LuaWidget(player: this);
  }
}

class LuaWidget extends StatefulWidget {
  final LuaPlayer player;
  const LuaWidget({super.key, required this.player});

  @override
  State<LuaWidget> createState() => _LuaWidgetState();
}

class _LuaWidgetState extends State<LuaWidget> {
  @override
  void initState() {
    super.initState();
    widget.player.canvasState.onUpdate = _onUpdate;
  }

  void _onUpdate() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    widget.player.canvasState.onUpdate = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: GlobalCanvasPainter(widget.player.canvasState.commands),
      size: Size.infinite,
    );
  }
}

const String ooWrapper = '''
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
