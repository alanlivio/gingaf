import 'abstract.dart';
import 'lua.dart';
import 'html.dart';
import 'ssml.dart';
import 'text.dart';
import 'image.dart';

class PlayerFactory {
  static final Map<String, Player Function()> _registry = {
    for (var mime in LuaPlayer.handledMimeTypes) mime: () => LuaPlayer(),
    for (var mime in HTMLPlayer.handledMimeTypes) mime: () => HTMLPlayer(),
    for (var mime in SsmlPlayer.handledMimeTypes) mime: () => SsmlPlayer(),
    for (var mime in TextPlayer.handledMimeTypes) mime: () => TextPlayer(),
    for (var mime in ImagePlayer.handledMimeTypes) mime: () => ImagePlayer(),
  };

  static Player? getPlayer(String mimeType, String uri) {
    if (_registry.containsKey(mimeType)) {
      final player = _registry[mimeType]!();
      player.init(uri);
      return player;
    }
    return null;
  }
  
  static String getMimeTypeFromExtension(String fileName) {
    final ext = fileName.split('.').last.toLowerCase();
    switch (ext) {
      case 'lua': return 'application/x-ginga-NCLua';
      case 'html': return 'text/html';
      case 'ssml': return 'application/ssml+xml';
      case 'txt': return 'text/plain';
      case 'png': return 'image/png';
      case 'bmp': return 'image/bmp';
      case 'webp': return 'image/webp';
      case 'gif': return 'image/gif';
      case 'jpeg':
      case 'jpg': return 'image/jpeg';
      case 'heic':
      case 'heif': return 'image/heic';
      default: return 'application/octet-stream';
    }
  }
}
