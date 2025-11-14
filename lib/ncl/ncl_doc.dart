class NCLMedia {
  final String id;
  final String src;
  final String? type;

  NCLMedia({
    required this.id,
    required this.src,
    this.type,
  });
}

class NCLPort {
  final String id;
  final String component;
  final String? interface;

  NCLPort({
    required this.id,
    required this.component,
    this.interface,
  });
}

class NCLDocument {
  final List<NCLMedia> mediaList;
  final List<NCLPort> portList;

  NCLDocument({
    required this.mediaList,
    required this.portList,
  });
}
