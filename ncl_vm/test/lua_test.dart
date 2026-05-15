import 'package:test/test.dart';
import 'package:ncl_vm/ncl_vm.dart';

void main() {
  group('NCLua Tests', () {
    late NCLua engine;
    setUp(() {
      engine = NCLua();
    });
    test('Lua script can call attrColor and populate buffer', () {
      final script = '''
        local c = canvas.new()
        c:attrColor(255, 100, 50, 200)
      ''';
      engine.execute(script);
      expect(engine.canvasCalls.length, 1);
      expect(engine.canvasCalls[0].method, 'attrColor');
      expect(engine.canvasCalls[0].args, [255, 100, 50, 200]);
    });
    test('Lua script can call drawRect and populate buffer', () {
      final script = '''
        local c = canvas.new()
        c:drawRect('stroke', 10, 20, 100, 200)
      ''';
      engine.execute(script);
      expect(engine.canvasCalls.length, 1);
      expect(engine.canvasCalls[0].method, 'drawRect');
      expect(engine.canvasCalls[0].args, ['stroke', 10.0, 20.0, 100.0, 200.0]);
    });
    test('Named colors are correctly mapped in Lua wrapper', () {
      final script = '''
        local c = canvas.new()
        c:attrColor('red')
      ''';
      engine.execute(script);
      expect(engine.canvasCalls.length, 1);
      expect(engine.canvasCalls[0].method, 'attrColor');
      expect(engine.canvasCalls[0].args, [255, 0, 0, 255]);
    });
    test('clearBuffer empties the calls list', () {
      engine.execute('canvas.new():drawRect("fill", 0, 0, 1, 1)');
      expect(engine.canvasCalls.isNotEmpty, true);
      engine.clearBuffer();
      expect(engine.canvasCalls.isEmpty, true);
    });
  });
}
