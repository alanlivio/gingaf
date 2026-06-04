import 'dart:io';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:gingaf/ncl/widgets/base.dart';
import 'package:webview_all/webview_all.dart';

final _logger = Logger('ginga-html');

class HTMLApp extends StatefulWidget {
  final String uri;
  final Map<String, void Function(JavaScriptMessage)>? javaScriptChannels;

  const HTMLApp({super.key, required this.uri, this.javaScriptChannels});

  @override
  State<HTMLApp> createState() => HTMLAppState();
}

class HTMLAppState extends BaseWidgetState<HTMLApp> {
  late final WebViewController _controller;
  bool _initialized = false;
  bool _loadStarted = false;

  @override
  void initState() {
    super.initState();
    _logger.info("Starting HTML application: ${widget.uri}");
    _controller = WebViewController()
      ..setBackgroundColor(const Color(0x00000000));

    widget.javaScriptChannels?.forEach((name, callback) {
      _controller.addJavaScriptChannel(name, onMessageReceived: callback);
    });

    initPlayer(widget.uri);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_loadStarted) {
      _loadStarted = true;
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
      _logger.severe("Error loading ${widget.uri}: $e");
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
  void dispose() {
    _logger.info("Stopping HTML application: ${widget.uri}");
    super.dispose();
  }

  @override
  Widget buildWidgetContent(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        color: Colors.white,
        child: _initialized
            ? WebViewWidget(controller: _controller)
            : const Center(child: CircularProgressIndicator()),
      ),
    );
  }
}
