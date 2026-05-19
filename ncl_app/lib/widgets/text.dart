import 'package:flutter/material.dart';
import 'base.dart';

class TextPlayer extends StatefulWidget {
  final String uri;
  const TextPlayer({super.key, required this.uri});

  @override
  State<TextPlayer> createState() => TextPlayerState();
}

class TextPlayerState extends PlayerState<TextPlayer> {
  @override
  void initState() {
    super.initState();
    initPlayer(widget.uri);
  }

  @override
  Widget build(BuildContext context) {
    return const Center(
        child: Text("TextPlayer: Not Implemented",
            style: TextStyle(color: Colors.red)));
  }
}
