import 'dart:async';

import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:ncl_doc/ncl_document.dart' hide State;

import 'widgets/base.dart';

export 'widgets/av.dart';
export 'widgets/base.dart';
export 'widgets/image.dart';
export 'widgets/lua.dart';
export 'widgets/ssml.dart';
export 'widgets/text.dart';

final _logger = Logger('ginga-ncl');

class NCLAppExitNotification extends Notification {}

class NCLApp extends StatefulWidget {
  final String uri;

  const NCLApp({
    super.key,
    required this.uri,
  });

  @override
  State<NCLApp> createState() => NCLAppState();
}

class NCLAppState extends BaseWidgetState<NCLApp> {
  NCLDocument? nclDocument;
  Timer? _ticker;
  String errorMsg = "";
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _logger.info("Starting NCL application: ${widget.uri}");
    initPlayer(widget.uri);
    _startApplication();
  }

  Future<void> _startApplication() async {
    if (_loading) return;
    _loading = true;
    try {
      if (mounted) {
        setState(() {});
      }

      final String nclData = await loadContent(widget.uri);
      final doc = NCLDocument.fromXML(nclData);

      nclDocument = doc;
      doc.start();

      if (mounted) {
        setState(() {
          errorMsg = "";
        });
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          DateTime lastTick = DateTime.now();
          _ticker = Timer.periodic(const Duration(milliseconds: 100), (timer) {
            if (mounted) {
              final now = DateTime.now();
              final deltaMs = now.difference(lastTick).inMilliseconds;
              lastTick = now;
              nclDocument?.tick(deltaMs);
              if (nclDocument != null) {
                if (!nclDocument!.isPlaying) {
                  _ticker?.cancel();
                  _ticker = null;
                  nclDocument = null;
                  if (mounted) {
                    setState(() {});
                  }
                  NCLAppExitNotification().dispatch(context);
                } else if (mounted) {
                  setState(() {});
                }
              }
            }
          });
        });
      }
    } catch (e, stacktrace) {
      _logger.severe("Error: $e\n$stacktrace");
      if (mounted) {
        setState(() {
          errorMsg = "Error: $e";
        });
      }
    } finally {
      _loading = false;
    }
  }

  @override
  void dispose() {
    _logger.info("Stopping NCL application: ${widget.uri}");
    _ticker?.cancel();
    final doc = nclDocument;
    nclDocument = null;
    doc?.stop();
    super.dispose();
  }

  @override
  Widget buildWidgetContent(BuildContext context) {
    final String nclBase = widget.uri.contains('/')
        ? widget.uri.substring(0, widget.uri.lastIndexOf('/') + 1)
        : "";

    final activeMedia = nclDocument?.getActiveMedia() ?? [];

    final List<Widget> widgets = [];
    for (var media in activeMedia) {
      final src = media.rawAttributes['src'] ?? '';
      final contentPath = src.isEmpty
          ? ''
          : (src.startsWith('http')
              ? src
              : (src.contains('/') ? src : "$nclBase$src"));

      widgets.add(
        KeyedSubtree(
          key: ValueKey(media.id),
          child: WidgetFactory.createWidget(
                media.mimeType,
                contentPath,
                media: media,
              ) ??
              const SizedBox.shrink(),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        fit: StackFit.expand,
        children: widgets,
      ),
    );
  }
}
