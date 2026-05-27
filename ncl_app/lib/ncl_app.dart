import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:ncl_doc/ncl_document.dart' hide State;
import 'package:ncl_doc/ncl_document.dart' as vm show State;

import 'widgets/base.dart';

export 'widgets/base.dart';
export 'widgets/image.dart';
export 'widgets/lua.dart';
export 'widgets/ssml.dart';
export 'widgets/text.dart';
export 'widgets/av.dart';

const RUNTIME = kIsWeb ? 'gingancl(browser)' : 'gingancl';

class NCLApp extends StatefulWidget {
  final String uri;
  final void Function(String? uri)? onBackgroundVideoChanged;

  const NCLApp({
    super.key,
    required this.uri,
    this.onBackgroundVideoChanged,
  });

  @override
  State<NCLApp> createState() => NCLAppState();
}

class NCLAppState extends BaseWidgetState<NCLApp> {
  late final NCLDocument nclDocument;
  final Map<String, Widget> _activeWidgets = {};
  String errorMsg = "";

  @override
  void initState() {
    super.initState();
    initPlayer(widget.uri);
    _startApplication();
  }

  Future<void> _startApplication() async {
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

      nclDocument = NCLDocument(nclData);

      final settings = nclDocument.getSettings();
      if (settings != null) {
        settings.addPropertyChangeListener((name, value) {
          if (name == 'videoUri') {
            widget.onBackgroundVideoChanged?.call(value?.toString());
          }
        });
        final initialVideo = settings.getProperty('videoUri');
        if (initialVideo != null) {
          widget.onBackgroundVideoChanged?.call(initialVideo.toString());
        }
      }

      final mediaNodes = nclDocument.elements.whereType<Media>().toList();
      for (var media in mediaNodes) {
        media.lambda.addStateListener((oldState, newState) {
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
                media.lambda.transition(ActionType.STOP);
              },
            );

            if (widgetInstance != null && mounted) {
              setState(() {
                _activeWidgets[media.id] = widgetInstance;
              });
            }
          } else if (newState == vm.State.SLEEPING && mounted) {
            setState(() {
              _activeWidgets.remove(media.id);
            });
          }
        });
      }

      nclDocument.start();

      if (mounted) {
        setState(() {
          errorMsg = "";
        });
      }
    } catch (e, stacktrace) {
      print("$RUNTIME Error: $e\n$stacktrace");
      if (mounted) {
        setState(() {
          errorMsg = "Error: $e";
        });
      }
    }
  }

  @override
  void dispose() {
    nclDocument.stop();
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
      floatingActionButton: FloatingActionButton(
        onPressed: _startApplication,
        mini: true,
        tooltip: 'Reload NCL',
        child: const Icon(Icons.refresh),
      ),
    );
  }
}
