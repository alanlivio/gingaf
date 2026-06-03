import 'package:flutter/material.dart';
import 'package:ncl_doc/ncl_document.dart' hide State;
import 'base.dart';

class ImageWidget extends StatefulWidget {
  final String uri;
  final Media? media;
  const ImageWidget({super.key, required this.uri, this.media});

  @override
  State<ImageWidget> createState() => ImageWidgetState();
}

class ImageWidgetState extends BaseWidgetState<ImageWidget> {
  @override
  void initState() {
    super.initState();
    initPlayer(widget.uri);
    parseProperties(widget.media);
  }

  @override
  Widget buildWidgetContent(BuildContext context) {
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
