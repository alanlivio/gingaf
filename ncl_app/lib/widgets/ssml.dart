import 'package:flutter/material.dart';
import 'base.dart';

class SsmlPlayer extends StatefulWidget {
  final String uri;
  const SsmlPlayer({super.key, required this.uri});

  @override
  State<SsmlPlayer> createState() => SsmlPlayerState();
}

class SsmlPlayerState extends PlayerState<SsmlPlayer> {
  @override
  void initState() {
    super.initState();
    initPlayer(widget.uri);
  }

  @override
  Widget build(BuildContext context) {
    return const Center(
        child: Text("SsmlPlayer: Not Implemented",
            style: TextStyle(color: Colors.red)));
  }
}
