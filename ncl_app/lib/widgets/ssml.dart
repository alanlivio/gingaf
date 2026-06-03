import 'package:flutter/material.dart';
import 'package:ncl_doc/ncl_document.dart' hide State;
import 'base.dart';

class SsmlWidget extends StatefulWidget {
  final String uri;
  final Media? media;
  const SsmlWidget({super.key, required this.uri, this.media});

  @override
  State<SsmlWidget> createState() => SsmlWidgetState();
}

class SsmlWidgetState extends BaseWidgetState<SsmlWidget> {
  @override
  void initState() {
    super.initState();
    initPlayer(widget.uri);
    parseProperties(widget.media);
  }

  @override
  Widget buildWidgetContent(BuildContext context) {
    return const Center(
        child: Text("SsmlWidget: Not Implemented",
            style: TextStyle(color: Colors.red)));
  }
}
