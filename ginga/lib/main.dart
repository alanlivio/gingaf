import 'dart:io';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';

import 'ginga.dart';

final _logger = Logger('ginga');
const USAGE = '''
Usage:
  flutter run --dart-define="APP=path/to/app.{ncl|html}" 
  Options:
    --dart-define="MAINAV=path/to/video.mp4"  Set background video URI
''';

void main() {
  Logger.root.level = Level.ALL;
  Logger.root.onRecord.listen((record) {
    debugPrint(
        '[${record.loggerName}] ${record.level.name}: ${record.message}');
  });

  final config = GingaConfig();
  if (config.isEmpty) {
    if (kIsWeb) {
      _logger.info('Running in web without APP. Defaulting to empty playground player.');
      runApp(Ginga(config: GingaConfig(null, false, null)));
      return;
    }
    stdout.writeln(USAGE);
    exit(0);
  }
  _logger.info(config.toString());

  if (!kIsWeb) {
    _logger.info('Initial working directory: ${Directory.current.path}');
    try {
      if (stdin.hasTerminal) {
        stdin.echoMode = false;
        stdin.lineMode = false;
      }
      stdin.listen((List<int> codes) {
        if (codes.contains(27)) {
          _logger.info('Captured ESC, stopping app.');
          exit(0);
        }
      });
    } catch (e) {
      _logger.severe('Failed to setup stdin listener: $e');
    }
  }

  WidgetsFlutterBinding.ensureInitialized();

  if (!kIsWeb) {
    try {
      final file = File(config.appPath!).absolute;
      _logger.info('Resolved app path: ${file.path}');
      if (file.existsSync()) {
        Directory.current = file.parent.path;
        _logger.info('Switched working directory to ${Directory.current.path}');
      }
    } catch (e) {
      _logger.severe('Failed to set working directory: $e');
    }
  }

  runApp(Ginga(config: config));
}
