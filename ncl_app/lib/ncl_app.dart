import 'dart:async';

import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:ncl_doc/ncl_document.dart' as vm show State;
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
  final Map<String, Widget> _activeWidgets = {};
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
        setState(() {
          _activeWidgets.clear();
        });
      }

      final String nclData = await loadContent(widget.uri);

      final String nclBase = widget.uri.contains('/')
          ? widget.uri.substring(0, widget.uri.lastIndexOf('/') + 1)
          : "";

      final doc = NCLDocument.fromXML(nclData);

      List<Media> getMediaNodes(Composition comp) {
        final medias = <Media>[];
        for (var node in comp.getNodes()) {
          if (node is Media) medias.add(node);
          if (node is Composition) medias.addAll(getMediaNodes(node));
        }
        return medias;
      }

      final mediaNodes = getMediaNodes(doc.getBody());
      for (var media in mediaNodes) {
        media.getMainEvent().addStateListener((oldState, newState) {
          if (newState == vm.State.OCCURRING) {
            final src = media.rawAttributes['src'] ?? '';
            var mimeType = media.rawAttributes['type'];
            if (mimeType == null || mimeType.isEmpty) {
              mimeType = WidgetFactory.getMimeTypeFromExtension(src);
            }
            final contentPath = src.startsWith('http')
                ? src
                : (src.contains('/') ? src : "$nclBase$src");

            final widgetInstance = WidgetFactory.createWidget(
              mimeType,
              contentPath,
              media: media,
              onVideoStopped: () {
                media.getMainEvent().doAction(ActionType.STOP);
              },
            );

            if (widgetInstance != null && mounted) {
              if (nclDocument == null) return;
              setState(() {
                _activeWidgets[media.id] = widgetInstance;
              });
            }
          } else if (newState == vm.State.SLEEPING && mounted) {
            if (nclDocument == null) return;
            setState(() {
              _activeWidgets.remove(media.id);
            });
          }
        });
      }

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
              if (nclDocument != null && !nclDocument!.isPlaying) {
                _ticker?.cancel();
                _ticker = null;
                nclDocument = null;
                _activeWidgets.clear();
                if (mounted) {
                  setState(() {});
                }
                NCLAppExitNotification().dispatch(context);
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
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        fit: StackFit.expand,
        children: _activeWidgets.values.toList(),
      ),
    );
  }
}
