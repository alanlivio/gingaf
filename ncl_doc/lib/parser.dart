import 'package:xml/xml.dart';
import 'schema.dart';
import 'ncl_document.dart';

class NCLParser {
  final Schema schema = Schema();

  NCLParser();

  NCLDocument parseString(String xmlString) {
    final document = XmlDocument.parse(xmlString);
    final root = document.rootElement;
    final rootElement = _parseNode(root);

    final allElements = <NCLXMLElement>[];
    void collect(NCLXMLElement e) {
      allElements.add(e);
      for (var child in e.children) {
        collect(child);
      }
    }

    if (rootElement != null) {
      collect(rootElement);
    }

    return NCLDocument.fromElements(allElements);
  }

  NCLXMLElement? _parseNode(XmlElement node) {
    Map<String, String> attrs = {
      for (var attr in node.attributes) attr.name.local: attr.value,
    };
    String id = attrs['id'] ?? '';

    final NCLXMLElement element;
    switch (node.name.local) {
      case 'media':
        element = Media(id: id, rawAttributes: attrs);
        break;
      case 'context':
        element = Context(id: id, rawAttributes: attrs);
        break;
      case 'region':
        element = Region(id: id, rawAttributes: attrs);
        break;
      case 'descriptor':
        element = Descriptor(id: id, rawAttributes: attrs);
        break;
      case 'link':
        element = Link(id: id, rawAttributes: attrs);
        break;
      case 'connector':
      case 'causalConnector':
        element = Connector(id: id, rawAttributes: attrs);
        break;
      case 'port':
        element = Port(id: id, rawAttributes: attrs);
        break;
      case 'bind':
        element = Bind(rawAttributes: attrs);
        break;
      case 'property':
        element = Property(id: id, rawAttributes: attrs);
        break;
      case 'area':
        element = Area(id: id, rawAttributes: attrs);
        break;
      case 'switch':
        element = Switch(id: id, rawAttributes: attrs);
        break;
      case 'settings':
        element = Settings(id: id, rawAttributes: attrs);
        break;
      default:
        // Generic element for structural nodes like <ncl>, <head>, <body>
        element = NCLXMLElement(
          id: id.isNotEmpty ? id : node.name.local,
          rawAttributes: attrs,
        );
    }

    for (var childNode in node.children.whereType<XmlElement>()) {
      final childElement = _parseNode(childNode);
      if (childElement != null) {
        element.children.add(childElement);
        if (element is Context && childElement is Link) {
          element.links.add(childElement);
        }
        if (element is Composition && childElement is Node) {
          childElement.parent = element;
        }
      }
    }

    return element;
  }

  List<String> validate(String xmlString) {
    final errors = <String>[];
    try {
      final document = XmlDocument.parse(xmlString);
      for (var node in document.descendants) {
        if (node is XmlElement) {
          errors.addAll(schema.validateElement(node));
        }
      }
    } catch (e) {
      errors.add('Invalid XML format: $e');
    }
    return errors;
  }
}
