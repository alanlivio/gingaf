import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'ncl_parser.dart';
import 'players/base.dart';

const RUNTIME = kIsWeb ? 'gingancl(browser)' : 'gingancl';

class NCLPlayer extends StatefulWidget {
  final String uri;
  const NCLPlayer({super.key, required this.uri});

  @override
  State<NCLPlayer> createState() => NCLPlayerState();
}

class NCLPlayerState extends PlayerState<NCLPlayer> {
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

      final nclDoc = NCLParser.parse(nclData);

      if (mounted) {
        setState(() => runtimeStatus = "Parsing Ports (${nclDoc.portList.length})...");
      }

      for (var port in nclDoc.portList) {
        final media = nclDoc.mediaList.firstWhere(
          (m) => m.id == port.component,
          orElse: () => throw Exception(
              "Media component '${port.component}' referenced by port '${port.id}' not found"),
        );

        final src = media.src;
        String? mimeType = media.type;
        if (mimeType == null || mimeType.isEmpty) {
          mimeType = PlayerFactory.getMimeTypeFromExtension(src);
        }

        if (mounted) {
          setState(() => runtimeStatus = "Launching: $src ($mimeType)");
        }

        final contentPath = src.startsWith('http') ? src : (src.contains('/') ? src : "$nclBase$src");
        
        if (mounted) {
          setState(() {
            final playerWidget = PlayerFactory.createPlayer(mimeType!, contentPath);
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
