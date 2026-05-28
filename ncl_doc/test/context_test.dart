import 'package:ncl_doc/ncl_document.dart';
import 'package:test/test.dart';

void main() {
  group('Context Tests', () {
    test('Context Initialization', () {
      final context = Context(id: 'c1', rawAttributes: {'id': 'c1'});
      expect(context, isA<Context>());
      expect(context.id, 'c1');
    });

    test('getRoot is returned correctly when provided', () {
      final root = Context(id: 'c1');
      final doc = NCLDocument.fromElements([root]);
      expect(doc.getRoot(), root);
    });
  });

  test('trigger links only within target Context', () {
    final m1 = Media(id: 'm1');
    final m2 = Media(id: 'm2');
    final context1 = Context(id: 'c1');
    context1.children.addAll([m1, m2]);
    m1.parent = context1;
    m2.parent = context1;

    final link1 = Link(id: 'l1');
    link1.children.add(
      Bind(rawAttributes: {'role': 'onBegin', 'component': 'm1'}),
    );
    link1.children.add(
      Bind(rawAttributes: {'role': 'start', 'component': 'm2'}),
    );
    context1.links.add(link1);

    final m3 = Media(id: 'm3');
    final m4 = Media(id: 'm4');
    final context2 = Context(id: 'c2');
    context2.children.addAll([m3, m4]);
    m3.parent = context2;
    m4.parent = context2;

    final link2 = Link(id: 'l2');
    link2.children.add(
      Bind(rawAttributes: {'role': 'onBegin', 'component': 'm1'}),
    );
    link2.children.add(
      Bind(rawAttributes: {'role': 'start', 'component': 'm4'}),
    );
    context2.links.add(link2);

    final port = Port(id: 'p1', rawAttributes: {'component': 'm1'});

    final vm = NCLDocument.fromElements([
      context1,
      m1,
      m2,
      context2,
      m3,
      m4,
      port,
    ]);
    vm.tickTo(0);
    expect(vm.getLambdaState('m1'), State.OCCURRING);
    expect(vm.getLambdaState('m2'), State.OCCURRING);
    expect(vm.getLambdaState('m4'), State.SLEEPING);
  });
}
