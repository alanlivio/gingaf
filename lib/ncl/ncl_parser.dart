import 'package:xml/xml.dart';

import 'ncl_doc.dart';

class NCLParser {
  static NCLDocument parse(String nclContent) {
    final document = XmlDocument.parse(nclContent);

    final mediaList = document.findAllElements('media').map((e) {
      return NCLMedia(
        id: e.getAttribute('id') ?? '',
        src: e.getAttribute('src') ?? '',
        type: e.getAttribute('type'),
      );
    }).toList();

    final portList = document.findAllElements('port').map((e) {
      return NCLPort(
        id: e.getAttribute('id') ?? '',
        component: e.getAttribute('component') ?? '',
        interface: e.getAttribute('interface'),
      );
    }).toList();

    return NCLDocument(
      mediaList: mediaList,
      portList: portList,
    );
  }
}
