import 'package:flutter/material.dart';
import 'abstract.dart';

class ImagePlayer with Player {
  static List<String> get handledMimeTypes => [
    'image/png',
    'image/jpeg',
    'image/gif',
    'image/webp'
  ];

  @override
  void init(String uri) {
    this.uri = uri;
  }

  @override
  Future<void> start() async {
    state = PlayerState.occurring;
  }

  @override
  Future<void> stop() async {
    state = PlayerState.sleeping;
  }

  @override
  Future<void> pause() async {
    state = PlayerState.paused;
  }

  @override
  Future<void> resume() async {
    state = PlayerState.occurring;
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
