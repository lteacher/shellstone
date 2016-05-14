import 'package:test/test.dart';
import 'package:shellstone/shellstone.dart';
import '../test_setups.dart';

main() {
  setUpAll(() async {
    // Start shellstone to setup any annotations
    await strapIn();
  });

  group('Adapters', () {
    test('@Adapter(name) drops in a replacement adapter for shellstone', () {
      expect(adapters('mongo'),new isInstanceOf<CustomMongoAdapter>());
    });
  });
}
