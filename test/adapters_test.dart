import 'package:test/test.dart';
import 'package:shellstone/shellstone.dart';
import 'test_setups.dart';

main() {
  setUp(() {
    // Start shellstone to setup any annotations
    strapIn();
  });
  group('Adapters', () {
    test('@Adapter(name) drops in a replacement adapter for shellstone', () {
      expect(adapters('mongo'),new isInstanceOf<CustomMongoAdapter>());
    });
  });
}
