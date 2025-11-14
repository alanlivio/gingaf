import 'package:flutter/material.dart';
import 'abstract.dart';

class TextPlayer with Player {
  static List<String> get handledMimeTypes => ['text/plain'];

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
    return const Center(child: Text("TextPlayer: Not Implemented", style: TextStyle(color: Colors.red)));
  }
}
