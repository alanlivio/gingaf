import 'dart:io';

import 'package:flutter/material.dart';
import 'package:ncl_doc/ncl_document.dart' hide State;
import 'package:video_player/video_player.dart';
import 'ncl_media_widget.dart';

class AVWidget extends MediaWidget {
  const AVWidget({
    super.key,
    required super.uri,
    super.media,
  });

  @override
  State<AVWidget> createState() => AVWidgetState();
}

class AVWidgetState extends MediaState<AVWidget> {
  late VideoPlayerController _controller;
  bool _initialized = false;
  bool _isCompleted = false;

  @override
  void initState() {
    super.initState();
    parseProperties(widget.media);
    _initVideo();
  }

  Future<void> _initVideo() async {
    try {
      final uriStr = widget.uri;
      if (uriStr.startsWith('http://') || uriStr.startsWith('https://')) {
        _controller = VideoPlayerController.networkUrl(Uri.parse(uriStr));
      } else {
        _controller = VideoPlayerController.file(File(uriStr));
      }

      _controller.addListener(() {
        if (!_isCompleted &&
            _controller.value.isInitialized &&
            _controller.value.duration.inMilliseconds > 0 &&
            _controller.value.position >= _controller.value.duration) {
          _isCompleted = true;
        }
      });

      await _controller.initialize();
      await _controller.play();

      if (mounted) {
        setState(() {
          _initialized = true;
        });
      }
    } catch (e) {
      debugPrint("AVWidget Error initializing video: $e");
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget buildWidgetContent(BuildContext context) {
    if (!_initialized) {
      return const Center(child: CircularProgressIndicator());
    }
    return Center(
      child: AspectRatio(
        aspectRatio: _controller.value.aspectRatio,
        child: VideoPlayer(_controller),
      ),
    );
  }
}
