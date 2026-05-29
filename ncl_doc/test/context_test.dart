import 'package:ncl_doc/ncl_document.dart';
import 'package:test/test.dart';

void main() {
  group('Context Tests', () {
    test('Context Initialization', () {
      final context = Context(id: 'c1', rawAttributes: {'id': 'c1'});
      expect(context, isA<Context>());
      expect(context.id, 'c1');
    });

    test('getBody is returned correctly when provided', () {
      final c1 = Context(id: 'c1');
      final doc = NCLDocument.fromBodyElements([c1]);
      expect(doc.getBody().id, 'body');
      expect(doc.getBody().children.first.id, 'c1');
    });
  });
}
