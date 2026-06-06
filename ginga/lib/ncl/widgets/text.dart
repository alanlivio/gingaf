import 'package:flutter/material.dart';
import 'package:ncl_doc/ncl_document.dart' hide State;
import 'ncl_media_state.dart';

class TextWidget extends StatefulWidget {
  final String uri;
  final Media? media;
  const TextWidget({super.key, required this.uri, this.media});

  @override
  State<TextWidget> createState() => TextWidgetState();
}

class TextWidgetState extends NCLMediaState<TextWidget> {
  @override
  void initState() {
    super.initState();
    parseProperties(widget.media);
  }

  @override
  Widget buildWidgetContent(BuildContext context) {
    return const Center(
        child: Text("TextWidget: Not Implemented",
            style: TextStyle(color: Colors.red)));
  }
}
