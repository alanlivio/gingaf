import 'dart:io';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'ncl_parser.dart';
import 'players/abstract.dart';
import 'players/factory.dart';

const RUNTIME = kIsWeb ? 'gingancl(browser)' : 'gingancl';

class NCLApp extends StatelessWidget {
  final String uri;
  final String? content;
  const NCLApp({super.key, required this.uri, this.content});

  @override
  Widget build(BuildContext context) {
    return NCLScreen(uri: uri, content: content);
  }
}

class NCLScreen extends StatefulWidget {
  final String uri;
  final String? content;
  const NCLScreen({super.key, required this.uri, this.content});

  @override
  State<NCLScreen> createState() => _NCLScreenState();
}

class _NCLScreenState extends State<NCLScreen> {
  final List<Player> _activePlayers = [];
  String errorMsg = "";
  String status = "Initializing...";

  @override
  void initState() {
    super.initState();
    _startApplication();
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
    return await rootBundle.loadString(path);
  }

  Future<void> _startApplication() async {
    try {
      setState(() {
        status = "Loading NCL...";
        _activePlayers.clear();
      });

      final String nclData;
      if (widget.content != null) {
        nclData = widget.content!;
      } else {
        nclData = await _loadContent(widget.uri);
      }

      final String nclBase = widget.uri.contains('/')
          ? widget.uri.substring(0, widget.uri.lastIndexOf('/') + 1)
          : "";

      final nclDoc = NCLParser.parse(nclData);

      setState(() => status = "Parsing Ports (${nclDoc.portList.length})...");

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

        setState(() => status = "Launching: $src ($mimeType)");

        final mediaContent;
        if (src.startsWith('http')) {
          mediaContent = src;
        } else {
          final contentPath = src.contains('/') ? src : "$nclBase$src";
          mediaContent = await _loadContent(contentPath);
        }

        final player = PlayerFactory.getPlayer(mimeType, mediaContent);
        if (player == null) {
          throw Exception("No player found for MIME type: $mimeType");
        }

        await player.start();
        setState(() {
          _activePlayers.add(player);
        });
      }

      setState(() {
        status = "Running (${_activePlayers.length} active players)";
        errorMsg = "";
      });
    } catch (e, stacktrace) {
      print("$RUNTIME Error: $e\n$stacktrace");
      setState(() {
        errorMsg = "Error: $e";
        status = "Failed";
      });
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
          child: Text(status,
              style: const TextStyle(fontSize: 10, color: Colors.white70)),
        ),
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          ..._activePlayers.map((player) => player.build(context)).toList(),
          if (errorMsg.isNotEmpty)
            Container(
              color: Colors.white70,
              padding: const EdgeInsets.all(10),
              child: SingleChildScrollView(
                  child: Text(errorMsg,
                      style: const TextStyle(color: Colors.red, fontSize: 16))),
            ),
        ],
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
