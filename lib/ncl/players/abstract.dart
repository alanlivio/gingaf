import 'package:flutter/material.dart';

enum PlayerState {
  sleeping, // stopped
  occurring, // playing
  paused, // paused
}

/// Player interface and base implementation as a mixin.
/// This allows players to extend other classes while maintaining the Ginga contract.
mixin Player {
  Color bgColor = Colors.transparent;
  Rect rect = Rect.zero;
  Duration? duration;
  bool debug = false;
  bool visible = true;
  int alpha = 255;
  int zindex = 0;
  int zorder = 0;
  int focusIndex = 0;
  Color focusBorderColor = Colors.transparent;
  int focusBorderWidth = 0;
  int focusBorderTransparency = 0;
  Color selBorderColor = Colors.transparent;
  String type = "";
  String uri = "";
  PlayerState state = PlayerState.sleeping;

  void init(String uri);
  Future<void> start();
  Future<void> stop();
  Future<void> pause();
  Future<void> resume();
  Widget build(BuildContext context);
}
