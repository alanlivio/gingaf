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

  test('trigger links only within target Context', () {
    final m1 = Media(id: 'm1');
    final m2 = Media(id: 'm2');
    final pC1 = Port(id: 'p_c1', rawAttributes: {'component': 'm1'});
    final context1 = Context(id: 'c1');
    context1.children.addAll([pC1, m1, m2]);
    m1.parent = context1;
    m2.parent = context1;

    final link1 = Link(id: 'l1');
    link1.children.add(
      Bind(rawAttributes: {'role': 'onBegin', 'component': 'm1'}),
    );
    link1.children.add(
      Bind(rawAttributes: {'role': 'start', 'component': 'm2'}),
    );
    context1.children.add(link1);

    final m3 = Media(id: 'm3');
    final m4 = Media(id: 'm4');
    final pC2 = Port(id: 'p_c2', rawAttributes: {'component': 'm3'});
    final context2 = Context(id: 'c2');
    context2.children.addAll([pC2, m3, m4]);
    m3.parent = context2;
    m4.parent = context2;

    final link2 = Link(id: 'l2');
    link2.children.add(
      Bind(rawAttributes: {'role': 'onBegin', 'component': 'm3'}),
    );
    link2.children.add(
      Bind(rawAttributes: {'role': 'start', 'component': 'm4'}),
    );
    context2.children.add(link2);

    final p1 = Port(id: 'p1', rawAttributes: {'component': 'c1'});
    final p2 = Port(id: 'p2', rawAttributes: {'component': 'c2'});

    final doc = NCLDocument.fromBodyElements([p1, p2, context1, context2]);
    doc.tickTo(0);
    expect(doc.getNodeById('c1')?.getNodeState(), State.OCCURRING);
    expect(doc.getNodeById('c2')?.getNodeState(), State.OCCURRING);
    expect(doc.getNodeById('m1')?.getNodeState(), State.OCCURRING);
    expect(doc.getNodeById('m2')?.getNodeState(), State.OCCURRING);
    expect(doc.getNodeById('m3')?.getNodeState(), State.OCCURRING);
    expect(doc.getNodeById('m4')?.getNodeState(), State.OCCURRING);
  });
}
