import 'package:flutter/material.dart';
import 'package:ncl_doc/ncl_document.dart' hide State;
import 'ncl_media_state.dart';

class ImageWidget extends StatefulWidget {
  final String uri;
  final Media? media;
  const ImageWidget({super.key, required this.uri, this.media});

  @override
  State<ImageWidget> createState() => ImageWidgetState();
}

class ImageWidgetState extends NCLMediaState<ImageWidget> {
  @override
  void initState() {
    super.initState();
    parseProperties(widget.media);
  }

  @override
  Widget buildWidgetContent(BuildContext context) {
    if (widget.uri.isEmpty) {
      return const SizedBox.shrink();
    }
    return Image.network(
      widget.uri,
      fit: BoxFit.fill,
      width: double.infinity,
      height: double.infinity,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return const Center(child: CircularProgressIndicator());
      },
      errorBuilder: (context, error, stackTrace) {
        return const Center(child: Icon(Icons.error, color: Colors.red, size: 50));
      },
    );
  }
}
