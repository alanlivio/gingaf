import 'package:flutter/material.dart';
import 'package:ncl_doc/ncl_document.dart' hide State;
import 'base.dart';

class AVWidget extends StatefulWidget {
  final String uri;
  final Media? media;
  final VoidCallback? onVideoStopped;

  const AVWidget({
    super.key,
    required this.uri,
    this.media,
    this.onVideoStopped,
  });

  @override
  State<AVWidget> createState() => AVWidgetState();
}

class AVWidgetState extends BaseWidgetState<AVWidget> {
  @override
  void initState() {
    super.initState();
    initPlayer(widget.uri);
    parseAttributes(widget.media);
  }

  void simulateEnd() {
    widget.onVideoStopped?.call();
  }

  @override
  Widget buildWidgetContent(BuildContext context) {
    return Center(
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("AVWidget: ${widget.uri}"),
            ElevatedButton(
              onPressed: simulateEnd,
              child: const Text("Simulate End"),
            ),
          ],
        ),
      ),
    );
  }
}
