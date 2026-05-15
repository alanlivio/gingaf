import 'package:ncl_vm/ncl_vm.dart';
import 'package:test/test.dart';

void main() {
  group('NCLVM Tests', () {
    test('NCLVM initializes and starts ticking', () async {
      const xml = r'''
<ncl>
  <body>
    <port id="p1" component="m1"/>
    <media id="m1" src="media.mp4"/>
  </body>
</ncl>
''';
      final vm = NCLVM(xml);
      expect(vm.getLambdaState('m1'), State.SLEEPING);
      vm.start(ticksPerSecond: 100);
      await Future.delayed(Duration(milliseconds: 50));
      expect(vm.virtualClock, greaterThan(0));
      expect(vm.getLambdaState('m1'), State.OCCURRING);
      vm.stop();
    });

    test('tick increments virtual clock', () {
      final vm = NCLVM.fromDocument(Document());
      expect(vm.virtualClock, 0);
      vm.tick(10);
      expect(vm.virtualClock, 10);
      vm.tick();
      expect(vm.virtualClock, 11);
    });

    test('tickTo advances clock to specific time', () {
      final vm = NCLVM.fromDocument(Document());
      vm.tickTo(100);
      expect(vm.virtualClock, 100);
      vm.tickTo(50);
      expect(vm.virtualClock, 100);
    });

    test('automatic start via Port', () {
      final media = Media(id: 'm1');
      final port = Port(id: 'p1', rawAttributes: {'component': 'm1'});
      final document = Document([media, port]);
      final vm = NCLVM.fromDocument(document);
      expect(vm.getLambdaState('m1'), State.SLEEPING);
      vm.tickTo(0);
      expect(vm.getLambdaState('m1'), State.OCCURRING);
    });

    test('causal link between two media', () {
      final m1 = Media(id: 'm1');
      final m2 = Media(id: 'm2');
      final port = Port(id: 'p1', rawAttributes: {'component': 'm1'});
      final link = Link(id: 'l1');
      link.children.add(
        Bind(rawAttributes: {'role': 'onBegin', 'component': 'm1'}),
      );
      link.children.add(
        Bind(rawAttributes: {'role': 'start', 'component': 'm2'}),
      );
      final document = Document([m1, m2, port, link]);
      final vm = NCLVM.fromDocument(document);
      vm.tickTo(0);
      expect(vm.getLambdaState('m1'), State.OCCURRING);
      expect(vm.getLambdaState('m2'), State.OCCURRING);
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

      final document = Document([context1, m1, m2, context2, m3, m4, port]);
      final vm = NCLVM.fromDocument(document);

      vm.tickTo(0);
      expect(vm.getLambdaState('m1'), State.OCCURRING);
      expect(vm.getLambdaState('m2'), State.OCCURRING);
      expect(vm.getLambdaState('m4'), State.SLEEPING);
    });

    group('Parser-driven NCLVM Tests', () {
      test('state of media elements doc', () {
        const xmlString = '''
        <?xml version="1.0" encoding="UTF-8"?>
        <ncl>
          <body>
            <media id="video1" src="video.mp4" descriptor="desc1" />
            <media id="audio1" src="audio.mp3" descriptor="desc2" />
          </body>
        </ncl>
        ''';
        final vm = NCLVM(xmlString);

        expect(vm.getLambdaState('video1'), State.SLEEPING);
        expect(vm.getLambdaState('audio1'), State.SLEEPING);
        vm.tickTo(10);
        expect(vm.getLambdaState('video1'), State.SLEEPING);
      });

      test('state of nested contexts doc', () {
        const xmlString = '''
        <ncl>
          <body>
            <context id="c1">
              <media id="m1" src="media.mp4" />
              <context id="c2">
                <media id="m2" src="video.mp4" />
              </context>
            </context>
          </body>
        </ncl>
        ''';
        final vm = NCLVM(xmlString);

        expect(vm.getLambdaState('c1'), State.SLEEPING);
        expect(vm.getLambdaState('m1'), State.SLEEPING);
        expect(vm.getLambdaState('m2'), State.SLEEPING);
      });

      test('state of image.ncl', () {
        const String imageNcl = r'''
        <ncl>
          <body>
            <port id="init" component="ginga_logo"/>
            <media id="ginga_logo" src="https://upload.wikimedia.org/wikipedia/commons/c/ce/Ginga_Middleware_Logo.png" type="image/png"/>
          </body>
        </ncl>
        ''';
        final vm = NCLVM(imageNcl);

        expect(vm.getLambdaState('ginga_logo'), State.SLEEPING);
        vm.tickTo(0);
        expect(vm.getLambdaState('ginga_logo'), State.OCCURRING);
      });

      test('state of media with properties doc', () {
        const xmlString = '''
        <ncl>
          <body>
            <media id="lua_script" src="main.lua">
              <property name="fontColor" value="blue" />
            </media>
          </body>
        </ncl>
        ''';
        final vm = NCLVM(xmlString);
        expect(vm.getLambdaState('lua_script'), State.SLEEPING);
      });
    });
  });
}
