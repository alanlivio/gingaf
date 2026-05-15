import 'package:ncl_vm/ncl_vm.dart';
import 'package:test/test.dart';

void main() {
  group('Context Tests', () {
    test('Context element holds proper attributes', () {
      final context = Context(
        id: 'mainContext',
        rawAttributes: {'id': 'mainContext'},
      );
      expect(context.id, 'mainContext');
      expect(context.rawAttributes['id'], 'mainContext');
    });
  });
}
