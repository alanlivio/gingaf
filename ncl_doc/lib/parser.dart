import 'package:xml/xml.dart';

import 'mimetype.dart';
import 'ncl_document.dart';
import 'schema.dart';

class NCLParser {
  final Schema schema = Schema();

  NCLParser();

  (Head, Body) parseString(String xmlString) {
    final document = XmlDocument.parse(xmlString);
    final root = document.rootElement;

    Head head = [];
    Body body = Context(rawAttributes: const {'id': 'body'});

    for (var childNode in root.children.whereType<XmlElement>()) {
      if (childNode.name.local == 'head') {
        final headElement = _parseNode(childNode);
        if (headElement != null) {
          head = headElement.children;
        }
      } else if (childNode.name.local == 'body') {
        final bodyElement = _parseNode(childNode);
        if (bodyElement is Context) {
          body = bodyElement;
        }
      }
    }

    return (head, body);
  }

  Element? _parseNode(XmlElement node) {
    Map<String, String> attrs = {
      for (var attr in node.attributes) attr.name.local: attr.value,
    };
    final String id = attrs['id'] ?? '';

    final Element element;
    switch (node.name.local) {
      case 'media':
        final src = attrs['src'] ?? '';
        final type = attrs['type'] ?? '';
        final mimeType = type.isNotEmpty ? type : getMimeTypeFromExtension(src);
        if (mimeType == 'application/x-ncl-settings' ||
            mimeType == 'application/x-ginga-settings') {
          element = Settings(rawAttributes: attrs, mimeType: mimeType);
        } else {
          element = Media(rawAttributes: attrs, mimeType: mimeType);
        }
        break;
      case 'context':
      case 'body':
        element = Context(rawAttributes: attrs);
        break;
      case 'region':
        element = Region(rawAttributes: attrs);
        break;
      case 'descriptor':
        element = Descriptor(rawAttributes: attrs);
        break;
      case 'link':
        element = Link(rawAttributes: attrs);
        break;
      case 'connector':
      case 'causalConnector':
        element = Connector(rawAttributes: attrs);
        break;
      case 'port':
        element = Port(rawAttributes: attrs);
        break;
      case 'bind':
        element = Bind(rawAttributes: attrs);
        break;
      case 'property':
        element = Property(rawAttributes: attrs);
        break;
      case 'area':
        element = Area(rawAttributes: attrs);
        break;
      case 'switch':
        element = Switch(rawAttributes: attrs);
        break;
      case 'settings':
        element = Settings(rawAttributes: attrs);
        break;
      case 'head':
      case 'regionBase':
      case 'descriptorBase':
      case 'connectorBase':
        element = Element(rawAttributes: attrs);
        break;
      default:
        return null;
    }

    for (var childNode in node.children.whereType<XmlElement>()) {
      final childElement = _parseNode(childNode);
      if (childElement != null) {
        element.children.add(childElement);
        if (element is Composition && childElement is Node) {
          childElement.parent = element;
        }
      }
    }

    if (element is Node) {
      final explicitDurProp = element.children
          .whereType<Property>()
          .where((p) => p.name == 'explicitDur')
          .firstOrNull;
      if (explicitDurProp != null && explicitDurProp.value != null) {
        final durStr = explicitDurProp.value!;
        if (durStr.endsWith('ms')) {
          element.explicitDurMs = int.tryParse(durStr.replaceAll('ms', ''));
        } else if (durStr.endsWith('s')) {
          final s = double.tryParse(durStr.replaceAll('s', ''));
          if (s != null) {
            element.explicitDurMs = (s * 1000).toInt();
          }
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
