import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ncl_doc/ncl_document.dart' hide State;
import 'image.dart';
import 'lua.dart';
import 'ssml.dart';
import 'text.dart';
import 'av.dart';

abstract class BaseWidgetState<T extends StatefulWidget> extends State<T> {
  Color bgColor = Colors.transparent;
  Rect rect = Rect.zero;
  Duration? duration;
  bool debug = false;
  bool visible = true;
  int alpha = 255;
  int zindex = 0;
  int zorder = 0;
  int focusIndex = 0;
  Color focusBorderColor = Colors.transparent;
  int focusBorderWidth = 0;
  int focusBorderTransparency = 0;
  Color selBorderColor = Colors.transparent;
  String type = "";
  String uri = "";
  String? id;

  void initPlayer(String uri) {
    this.uri = uri;
  }

  void parseAttributes(Media? media) {
    if (media == null) return;
    id = media.id;
    final leftStr = media.rawAttributes['left'] ?? '';
    final topStr = media.rawAttributes['top'] ?? '';
    final widthStr = media.rawAttributes['width'] ?? '';
    final heightStr = media.rawAttributes['height'] ?? '';
    final visibleStr = media.rawAttributes['visible'] ?? 'true';
    visible = visibleStr.toLowerCase() == 'true';
    bgColor = _parseColor(media.rawAttributes['bgColor'] ?? media.rawAttributes['backgroundColor']);
    focusBorderColor = _parseColor(media.rawAttributes['focusBorderColor']);
    selBorderColor = _parseColor(media.rawAttributes['selBorderColor']);
    final left = double.tryParse(leftStr.replaceAll('%', '')) ?? 0.0;
    final top = double.tryParse(topStr.replaceAll('%', '')) ?? 0.0;
    final width = double.tryParse(widthStr.replaceAll('%', '')) ?? 100.0;
    final height = double.tryParse(heightStr.replaceAll('%', '')) ?? 100.0;
    rect = Rect.fromLTWH(left, top, width, height);
  }

  Color _parseColor(String? colorStr) {
    if (colorStr == null || colorStr.isEmpty) return Colors.transparent;
    if (colorStr.startsWith('#')) {
      final hex = colorStr.substring(1);
      if (hex.length == 6) {
        return Color(int.parse('FF$hex', radix: 16));
      } else if (hex.length == 8) {
        return Color(int.parse(hex, radix: 16));
      }
    }
    switch (colorStr.toLowerCase()) {
      case 'red': return Colors.red;
      case 'green': return Colors.green;
      case 'blue': return Colors.blue;
      case 'yellow': return Colors.yellow;
      case 'black': return Colors.black;
      case 'white': return Colors.white;
      default: return Colors.transparent;
    }
  }

  Future<String> loadContent(String path) async {
    if (!kIsWeb) {
      final file = File(path);
      if (file.existsSync()) {
        return await file.readAsString();
      }
      final fileName =
          path.contains('/') ? path.substring(path.lastIndexOf('/') + 1) : path;
      final localFile = File(fileName);
      if (localFile.existsSync()) {
        return await localFile.readAsString();
      }
    }
    final bundle =
        context.getInheritedWidgetOfExactType<DefaultAssetBundle>()?.bundle ??
            rootBundle;
    return await bundle.loadString(path);
  }

  String get playerKey => id ?? uri;

  @override
  Widget build(BuildContext context) {
    final content = Visibility(
      visible: visible,
      child: Opacity(
        opacity: alpha / 255.0,
        child: Container(
          decoration: BoxDecoration(
            color: bgColor,
            border: selBorderColor != Colors.transparent
                ? Border.all(color: selBorderColor, width: 3.0)
                : (focusBorderColor != Colors.transparent
                    ? Border.all(color: focusBorderColor, width: 2.0)
                    : null),
          ),
          child: buildWidgetContent(context),
        ),
      ),
    );
    if (rect == Rect.zero) {
      return content;
    }
    return Positioned.fromRect(
      rect: rect,
      child: content,
    );
  }

  Widget buildWidgetContent(BuildContext context);
}

class WidgetFactory {

  static Widget? createWidget(String mimeType, String uri, {Media? media}) {
    if (mimeType.startsWith('video/') || mimeType.startsWith('audio/') || mimeType.contains('video') || mimeType.contains('audio')) {
      return AVWidget(uri: uri, media: media);
    }
    switch (mimeType) {
      case 'application/x-ncl-NCLua':
      case 'application/x-ginga-NCLua':
        return LuaWidget(uri: uri, media: media);
      case 'application/ssml+xml':
        return SsmlWidget(uri: uri, media: media);
      case 'text/plain':
        return TextWidget(uri: uri, media: media);
      case 'image/png':
      case 'image/jpeg':
      case 'image/gif':
      case 'image/webp':
      case 'image/bmp':
      case 'image/heic':
        return ImageWidget(uri: uri, media: media);
      default:
        return null;
    }
  }
}
