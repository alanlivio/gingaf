// lib/xml_elements.dart

import 'ncl_document.dart';

typedef Head = List<NCLXMLElement>;
typedef Body = Context;

class NCLXMLElement {
  final Map<String, String> rawAttributes;
  final String id;
  final List<NCLXMLElement> children = [];

  NCLXMLElement({required this.id, this.rawAttributes = const {}});
}

class Port extends NCLXMLElement {
  String? get component => rawAttributes['component'];
  String? get interface => rawAttributes['interface'];
  Port({required super.id, super.rawAttributes});
}

class Bind extends NCLXMLElement {
  String? get role => rawAttributes['role'];
  String? get component => rawAttributes['component'];
  String? get interface => rawAttributes['interface'];
  // Bind often doesn't have an ID, so we'll use role as ID if missing
  Bind({String? id, super.rawAttributes})
    : super(id: id ?? 'bind_${rawAttributes['role']}');
}

class Property extends NCLXMLElement {
  String? get name => rawAttributes['name'];
  String? get value => rawAttributes['value'];
  Property({required super.id, super.rawAttributes});
}

class Area extends NCLXMLElement {
  String? get begin => rawAttributes['begin'];
  String? get end => rawAttributes['end'];
  Area({required super.id, super.rawAttributes});
}

class Link extends NCLXMLElement {
  Link({required super.id, super.rawAttributes});
}

class Descriptor extends NCLXMLElement {
  Descriptor({required super.id, super.rawAttributes});
}

class Region extends NCLXMLElement {
  Region({required super.id, super.rawAttributes});
}

class Connector extends NCLXMLElement {
  Connector({required super.id, super.rawAttributes});
}


abstract class Node extends NCLXMLElement {
  Composition? parent;
  int startTimestamp = 0;
  late final Event _presentationEvt = Event(
    type: EventType.PRESENTATION,
    targetNode: this,
  );

  Event getNodeEvent() => _presentationEvt;
  State getNodeState() => _presentationEvt.state;

  Node({required super.id, super.rawAttributes});
}

abstract class Composition extends Node {
  List<Node> getNodes() => children.whereType<Node>().toList();
  List<Port> getPorts() => children.whereType<Port>().toList();
  Composition({required super.id, super.rawAttributes});
}

class Context extends Composition {
  List<Link> getLinks() => children.whereType<Link>().toList();
  Context({required super.id, super.rawAttributes});
}

class Switch extends Composition {
  Switch({required super.id, super.rawAttributes});
}

class Media extends Node {
  Media({required super.id, super.rawAttributes});
  
  List<Property> getProperties() => children.whereType<Property>().toList();
  List<Area> getAreas() => children.whereType<Area>().toList();
}

class Settings extends Media {
  Settings({required super.id, super.rawAttributes});
}
