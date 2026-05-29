import 'dart:io';

import 'package:ccws/ccws.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:logging/logging.dart';

import 'package:ncl_app/ncl_app.dart' as ncl;

import 'html_app.dart' as html;
import 'main_av.dart';

final _logger = Logger('gingaf');
const USAGE = '''
Usage:
  flutter run --dart-define="APP=path/to/app.{ncl|html}" 
  Options:
    --dart-define="MAINAV=path/to/video.mp4"  Set background video URI
    --dart-define="CCWS=false"                Disable CCWS service (enabled by default)
''';

class GingaConfig {
  final String? appPath;
  final String? mainAvUri;
  final bool enableCCWS;

  GingaConfig([String? manualPath, bool? manualCCWS, String? manualVideo])
      : appPath = _resolve(manualPath),
        mainAvUri = manualVideo ?? _resolveVideo(),
        enableCCWS = manualCCWS ??
            const bool.fromEnvironment('CCWS', defaultValue: true);

  static String? _resolveVideo() {
    String? video = const String.fromEnvironment('MAINAV').isNotEmpty
        ? const String.fromEnvironment('MAINAV')
        : null;
    if (video == null && !kIsWeb) {
      video = Platform.environment['MAINAV'];
    }
    return video;
  }

  static String? _resolve(String? manualPath) {
    String? path = manualPath;

    if (path == null) {
      path = const String.fromEnvironment('APP').isNotEmpty
          ? const String.fromEnvironment('APP')
          : null;
      if (path == null && !kIsWeb) {
        path = Platform.environment['APP'];
      }
      if (path == null && !kIsWeb) {
        final file = File('.ginga_app');
        if (file.existsSync()) {
          path = file.readAsStringSync().trim();
        }
      }
    }

    if (path == null || path.isEmpty) return null;

    final lower = path.toLowerCase();
    if (!lower.endsWith('.ncl') && !lower.endsWith('.html')) {
      _logger.severe('\nUnsupported format: $path\n$USAGE');
      return null;
    }

    return path;
  }
}

void main() {
  Logger.root.level = Level.ALL;
  Logger.root.onRecord.listen((record) {
    debugPrint(
        '[${record.loggerName}] ${record.level.name}: ${record.message}');
  });

  if (!kIsWeb) {
    _logger.info('Initial working directory: ${Directory.current.path}');
    try {
      if (stdin.hasTerminal) {
        stdin.echoMode = false;
        stdin.lineMode = false;
      }
      stdin.listen((List<int> codes) {
        if (codes.contains(4)) {
          _logger.info('Captured Ctrl+D, stopping app.');
          SystemNavigator.pop();
        }
      });
    } catch (e) {
      _logger.severe('Failed to setup stdin listener: $e');
    }
  }

  final config = GingaConfig();
  if (config.appPath == null && config.mainAvUri == null) {
    if (!kIsWeb) {
      exit(0);
    } else {
      runApp(const MaterialApp(
        home: Scaffold(
          body: Center(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Text(USAGE, textAlign: TextAlign.center),
            ),
          ),
        ),
      ));
      return;
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

class Ginga extends StatefulWidget {
  final GingaConfig config;
  const Ginga({super.key, required this.config});

  @override
  State<Ginga> createState() => _GingaState();
}

class _GingaState extends State<Ginga> {
  late final CCWS _ccws;
  late final MainAVController mainAVController;
  late final Widget mainAVWidget;
  final GlobalKey<ncl.NCLAppState> nclAppKey = GlobalKey<ncl.NCLAppState>();
  Widget? htmlApp;
  Widget? nclApp;

  @override
  void initState() {
    super.initState();
    _ccws = CCWS();
    _logger.info('CCWS enabled: ${widget.config.enableCCWS}');
    if (widget.config.enableCCWS) {
      _ccws.start();
    }

    mainAVController = MainAVController()..setMainAvUri(widget.config.mainAvUri);
    mainAVWidget = MainAVWidget(controller: mainAVController);

    final path = widget.config.appPath;
    if (path != null) {
      if (path.toLowerCase().endsWith('.html')) {
        htmlApp = html.HTMLApp(
          uri: path,
        );
      } else {
        nclApp = ncl.NCLApp(
          key: nclAppKey,
          uri: path,
        );
      }
    }
    HardwareKeyboard.instance.addHandler(_handleKeyPress);
  }

  bool _handleKeyPress(KeyEvent event) {
    if (event is KeyDownEvent) {
      if (HardwareKeyboard.instance.isControlPressed &&
          event.logicalKey == LogicalKeyboardKey.keyD) {
        _logger.info('Captured Ctrl+D in Window, stopping app and mainAV.');
        nclAppKey.currentState?.nclDocument?.stop();
        mainAVController.stop();
        if (widget.config.enableCCWS) {
          _ccws.stop();
        }
        _logger.info('Exiting.');
        exit(0);
      }
    }
    return false;
  }

  @override
  void dispose() {
    HardwareKeyboard.instance.removeHandler(_handleKeyPress);
    if (widget.config.enableCCWS) {
      _ccws.stop();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final showUsage = htmlApp == null && nclApp == null && widget.config.mainAvUri == null;
    return MaterialApp(
      title: 'gingaf',
      themeMode: ThemeMode.light,
      theme: ThemeData(
        brightness: Brightness.light,
        scaffoldBackgroundColor: Colors.grey[200],
      ),
      home: Scaffold(
        body: showUsage
            ? const Center(
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: Text(USAGE, textAlign: TextAlign.center),
                ),
              )
            : Stack(
                fit: StackFit.expand,
                children: [
                  mainAVWidget,
                  if (htmlApp != null) htmlApp!,
                  if (nclApp != null) nclApp!,
                ],
              ),
      ),
    );
  }
}


