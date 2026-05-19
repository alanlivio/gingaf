import 'dart:io';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:ncl_app/widgets/base.dart';
import 'package:webview_all/webview_all.dart';

const RUNTIME = kIsWeb ? 'gingahtml(browser)' : 'gingahtml';

class HTMLApp extends StatefulWidget {
  final String uri;
  final void Function(JavaScriptMessage)? onMessageReceived;

  const HTMLApp({super.key, required this.uri, this.onMessageReceived});

  @override
  State<HTMLApp> createState() => HTMLAppState();
}

class HTMLAppState extends PlayerState<HTMLApp> {
  late final WebViewController _controller;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setBackgroundColor(const Color(0x00000000))
      ..addJavaScriptChannel("GingaBridge", onMessageReceived: (message) {
        print("$RUNTIME: GingaBridge message: ${message.message}");
        widget.onMessageReceived?.call(message);
      });

    initPlayer(widget.uri);
    _loadHTML();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      _loadHTML();
    }
  }

  Future<String> _loadContent(String path) async {
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
    return await DefaultAssetBundle.of(context).loadString(path);
  }

  Future<void> _loadHTML() async {
    try {
      final String content = await _loadContent(widget.uri);
      await _controller.loadHtmlString(content);
      if (mounted) {
        setState(() => _initialized = true);
      }
    } catch (e) {
      print("$RUNTIME: Error loading ${widget.uri}: $e");
      final errorHtml = """
        <!DOCTYPE html>
        <html>
        <body>
          <h1>Ginga HTML Runtime</h1>
          <p>Error loading: ${widget.uri}</p>
          <p style='color: red;'>$e</p>
        </body>
        </html>
      """;
      await _controller.loadHtmlString(errorHtml);
      if (mounted) {
        setState(() => _initialized = true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: const Text("ginga-html")),
      body: Container(
        color: Colors.white,
        child: _initialized
            ? WebViewWidget(controller: _controller)
            : const Center(child: CircularProgressIndicator()),
      ),
    );
  }
}
