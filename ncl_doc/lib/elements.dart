import 'ncl_document.dart';

typedef Head = List<Element>;
typedef Body = Context;

class Element {
  final Map<String, String> rawAttributes;
  final String id;
  final List<Element> children = [];

  Element({required this.id, this.rawAttributes = const {}});
}

class Port extends Element {
  String? get component => rawAttributes['component'];
  String? get interface => rawAttributes['interface'];
  Port({required super.id, super.rawAttributes});
}

class Bind extends Element {
  String? get role => rawAttributes['role'];
  String? get component => rawAttributes['component'];
  String? get interface => rawAttributes['interface'];
  Bind({String? id, super.rawAttributes})
    : super(id: id ?? 'bind_${rawAttributes['role']}');
}

class Property extends Element {
  String? get name => rawAttributes['name'];
  String? get value => rawAttributes['value'];
  Property({required super.id, super.rawAttributes});
}

class Area extends Element {
  String? get begin => rawAttributes['begin'];
  String? get end => rawAttributes['end'];
  Area({required super.id, super.rawAttributes});
}

class Link extends Element {
  Link({required super.id, super.rawAttributes});
}

class Descriptor extends Element {
  Descriptor({required super.id, super.rawAttributes});
}

class Region extends Element {
  Region({required super.id, super.rawAttributes});
}

class Connector extends Element {
  Connector({required super.id, super.rawAttributes});
}

abstract class Node extends Element {
  Composition? parent;
  int time = 0;
  int? explicitDurMs;
  late final Event _mainEvt = Event(
    type: EventType.PRESENTATION,
    targetNode: this,
    isMain: true,
  );
  final Map<String, Event> _areaEvents = {};
  Event getMainEvent() => _mainEvt;
  State getMainState() => _mainEvt.state;
  Event getAreaEvent(String areaId) {
    return _areaEvents.putIfAbsent(
      areaId,
      () => Event(
        type: EventType.PRESENTATION,
        targetNode: this,
        interfaceId: areaId,
      ),
    );
  }
  State getAreaEventState(String areaId) => getAreaEvent(areaId).state;
  List<Property> getProperties() => children.whereType<Property>().toList();
  List<Area> getAreas() => children.whereType<Area>().toList();
  Node({required super.id, super.rawAttributes});
}

abstract class Composition extends Node {
  int activeNodes = 0;
  List<Node> getNodes() => children.whereType<Node>().toList();
  Composition({required super.id, super.rawAttributes});
}

class Context extends Composition {
  List<Port> getPorts() => children.whereType<Port>().toList();
  List<Link> getLinks() => children.whereType<Link>().toList();
  Context({required super.id, super.rawAttributes});
}

class Switch extends Composition {
  Switch({required super.id, super.rawAttributes});
}

class Media extends Node {
  final String mimeType;
  Media({required super.id, super.rawAttributes, this.mimeType = 'application/octet-stream'});
}

class Settings extends Media {
  Settings({required super.id, super.rawAttributes, super.mimeType = 'application/x-ncl-settings'});
}
