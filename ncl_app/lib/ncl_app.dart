import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:ncl_vm/ncl_vm.dart' hide State;

import 'widgets/base.dart';

const RUNTIME = kIsWeb ? 'gingancl(browser)' : 'gingancl';

class NCLApp extends StatefulWidget {
  final String uri;
  const NCLApp({super.key, required this.uri});

  @override
  State<NCLApp> createState() => NCLAppState();
}

class NCLAppState extends PlayerState<NCLApp> {
  final List<Widget> _activePlayers = [];
  String errorMsg = "";
  String runtimeStatus = "Initializing...";

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
          runtimeStatus = "Loading NCL...";
          _activePlayers.clear();
        });
      }

      final String nclData = await loadContent(widget.uri);

      final String nclBase = widget.uri.contains('/')
          ? widget.uri.substring(0, widget.uri.lastIndexOf('/') + 1)
          : "";

      final nclVM = NCLVM(nclData);
      final document = nclVM.document;
      final ports = document.elements.whereType<Port>().toList();

      if (mounted) {
        setState(() => runtimeStatus = "Parsing Ports (${ports.length})...");
      }

      for (var port in ports) {
        final componentId = port.component;
        if (componentId == null || componentId.isEmpty) continue;

        final media = document.getNodeById(componentId);
        if (media == null || media is! Media) {
          throw Exception(
              "Media component '$componentId' referenced by port '${port.id}' not found");
        }

        final src = media.rawAttributes['src'] ?? '';
        String? mimeType = media.rawAttributes['type'];
        if (mimeType == null || mimeType.isEmpty) {
          mimeType = PlayerFactory.getMimeTypeFromExtension(src);
        }

        if (mounted) {
          setState(() => runtimeStatus = "Launching: $src ($mimeType)");
        }

        final contentPath = src.startsWith('http')
            ? src
            : (src.contains('/') ? src : "$nclBase$src");

        if (mounted) {
          setState(() {
            final playerWidget =
                PlayerFactory.createPlayer(mimeType!, contentPath);
            if (playerWidget != null) {
              _activePlayers.add(playerWidget);
            }
          });
        }
      }

      if (mounted) {
        setState(() {
          runtimeStatus = "Running (${_activePlayers.length} active players)";
          errorMsg = "";
        });
      }
    } catch (e, stacktrace) {
      print("$RUNTIME Error: $e\n$stacktrace");
      if (mounted) {
        setState(() {
          errorMsg = "Error: $e";
          runtimeStatus = "Failed";
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('ginga-ncl'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(20),
          child: Text(runtimeStatus,
              style: const TextStyle(fontSize: 10, color: Colors.white70)),
        ),
      ),
      body: Stack(
        fit: StackFit.expand,
        children: _activePlayers,
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
