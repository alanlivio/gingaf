import 'package:flutter/material.dart';
import 'package:ncl_doc/ncl_document.dart' hide State;
import 'base.dart';

class LuaWidget extends StatefulWidget {
  final String uri;
  final Media? media;
  const LuaWidget({super.key, required this.uri, this.media});

  @override
  State<LuaWidget> createState() => LuaWidgetState();
}

class LuaWidgetState extends BaseWidgetState<LuaWidget> {
  late NCLua _engine;
  final CanvasState canvasState = CanvasState();

  @override
  void initState() {
    super.initState();
    initPlayer(widget.uri);
    parseAttributes(widget.media);
    _engine = NCLua(delegate: canvasState);

    canvasState.onUpdate = () {
      if (mounted) setState(() {});
    };

    _runScript();
  }

  Future<void> _runScript() async {
    canvasState.reset();
    try {
      final script = await loadContent(uri);
      _engine.execute(script);
    } catch (e) {
      debugPrint("Lua Runtime Error: $e");
    }
  }

  @override
  Widget buildWidgetContent(BuildContext context) {
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

class CanvasState implements NCLCanvasDelegate {
  final List<DrawCommand> commands = [];
  Color currentColor = Colors.black;
  VoidCallback? onUpdate;

  void reset() {
    commands.clear();
    currentColor = Colors.black;
  }

  @override
  void attrColor(int r, int g, int b, int a) {
    currentColor = Color.fromARGB(a, r, g, b);
  }

  @override
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
