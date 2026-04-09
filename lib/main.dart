import 'dart:io';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';

import 'ccws/ccws.dart';
import 'html/html_player.dart' as html;
import 'ncl/ncl_player.dart' as ncl;

const GINGA = 'gingaf';
const USAGE = '''
Usage:
  flutter run --dart-define="APP=path/to/app.{ncl|html}" 
  Options:
    --dart-define="CCWS=false"  Disable CCWS service (enabled by default)
''';

class GingaConfig {
  final String? appPath;
  final bool enableCCWS;

  GingaConfig([String? manualPath, bool? manualCCWS])
      : appPath = _resolve(manualPath),
        enableCCWS = manualCCWS ??
            const bool.fromEnvironment('CCWS', defaultValue: true);

  static String? _resolve(String? manualPath) {
    String? path = manualPath;

    if (path == null) {
      path = const String.fromEnvironment('APP').isNotEmpty
          ? const String.fromEnvironment('APP')
          : null;

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
      print('\n[$GINGA ERROR] Unsupported format: $path\n$USAGE');
      return null;
    }

    return path;
  }
}

void main() {
  if (!kIsWeb) {
    print('$GINGA: Initial working directory: ${Directory.current.path}');
  }

  final config = GingaConfig();
  if (config.appPath == null) {
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
      print('$GINGA: Resolved app path: ${file.path}');
      if (file.existsSync()) {
        Directory.current = file.parent.path;
        print(
            '$GINGA: Switched working directory to ${Directory.current.path}');
      }
    } catch (e) {
      print('$GINGA: Failed to set working directory: $e');
    }
  }

  runApp(GingaApp(config: config));
}

class GingaApp extends StatefulWidget {
  final GingaConfig config;
  const GingaApp({super.key, required this.config});

  @override
  State<GingaApp> createState() => _GingaAppState();
}

class _GingaAppState extends State<GingaApp> {
  late final CCWS _ccws;

  @override
  void initState() {
    super.initState();
    _ccws = CCWS();
    print('$GINGA: CCWS enabled: ${widget.config.enableCCWS}');
    if (widget.config.enableCCWS) {
      _ccws.start();
    }
  }

  @override
  void dispose() {
    if (widget.config.enableCCWS) {
      _ccws.stop();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'gingaf',
      themeMode: ThemeMode.light,
      theme: ThemeData(
        brightness: Brightness.light,
        scaffoldBackgroundColor: Colors.grey[200],
      ),
      home: MainScreen(appPath: widget.config.appPath),
    );
  }
}

class MainScreen extends StatelessWidget {
  final String? appPath;
  const MainScreen({super.key, this.appPath});

  @override
  Widget build(BuildContext context) {
    if (appPath == null) {
      return const Scaffold(
        body: Center(
          child: Padding(
            padding: EdgeInsets.all(20),
            child: Text(USAGE, textAlign: TextAlign.center),
          ),
        ),
      );
    }

    if (appPath!.toLowerCase().endsWith('.html')) {
      return html.HTMLPlayer(uri: appPath!);
    } else {
      return ncl.NCLPlayer(uri: appPath!);
    }
  }
}
