import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'image.dart';
import 'lua.dart';
import 'ssml.dart';
import 'text.dart';

/// Base class for all player state classes.
/// Extends State and provides common media properties.
abstract class PlayerState<T extends StatefulWidget> extends State<T> {
  // Common player properties
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
}

class PlayerFactory {
  static final Map<String, List<String>> _extensionMap = {
    'lua': ['application/x-ginga-NCLua'],
    'html': ['text/html'],
    'ssml': ['application/ssml+xml'],
    'txt': ['text/plain'],
    'png': ['image/png'],
    'bmp': ['image/bmp'],
    'webp': ['image/webp'],
    'gif': ['image/gif'],
    'jpeg': ['image/jpeg'],
    'jpg': ['image/jpeg'],
    'heic': ['image/heic'],
    'heif': ['image/heic'],
  };

  static Widget? createPlayer(String mimeType, String uri) {
    switch (mimeType) {
      case 'application/x-ginga-NCLua':
        return LuaPlayer(uri: uri);
      case 'application/ssml+xml':
        return SsmlPlayer(uri: uri);
      case 'text/plain':
        return TextPlayer(uri: uri);
      case 'image/png':
      case 'image/jpeg':
      case 'image/gif':
      case 'image/webp':
      case 'image/bmp':
      case 'image/heic':
        return ImagePlayer(uri: uri);
      default:
        return null;
    }
  }

  static String getMimeTypeFromExtension(String fileName) {
    final ext = fileName.split('.').last.toLowerCase();
    for (var entry in _extensionMap.entries) {
      if (entry.key == ext) return entry.value.first;
    }
    return 'application/octet-stream';
  }
}
