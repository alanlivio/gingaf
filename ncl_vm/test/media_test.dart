import 'package:ncl_vm/ncl_vm.dart';
import 'package:test/test.dart';

void main() {
  group('Media Tests', () {
    test('Node properties can be observed', () {
      final media = Media(id: 'video1');
      bool listenerFired = false;
      dynamic updatedValue;
      media.addPropertyChangeListener((name, value) {
        if (name == 'bounds') {
          listenerFired = true;
          updatedValue = value;
        }
      });
      media.setProperty('bounds', '0,0,100,100');
      expect(listenerFired, isTrue);
      expect(updatedValue, '0,0,100,100');
      expect(media.getProperty('bounds'), '0,0,100,100');
    });
  });
}
