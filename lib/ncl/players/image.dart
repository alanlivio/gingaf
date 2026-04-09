import 'package:flutter/material.dart';
import 'base.dart';

class ImagePlayer extends StatefulWidget {
  final String uri;
  const ImagePlayer({super.key, required this.uri});

  @override
  State<ImagePlayer> createState() => ImagePlayerState();
}

class ImagePlayerState extends PlayerState<ImagePlayer> {
  @override
  void initState() {
    super.initState();
    initPlayer(widget.uri);
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Image.network(
        uri,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return const CircularProgressIndicator();
        },
        errorBuilder: (context, error, stackTrace) {
          return const Icon(Icons.error, color: Colors.red, size: 50);
        },
      ),
    );
  }
}
