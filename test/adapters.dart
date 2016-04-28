import 'package:test/test.dart';
import '../lib/shellstone.dart';
// import 'setups.dart';

main() {
  setUp(() {
    // Start shellstone to setup any annotations
    Shellstone.setup();
  });

  group('Adapters', () {
    test('Adapter is configure handler is called', () {
      expect(configureCalled, equals(true));
    });

    test('Adapter is connect handler is called', () {
      expect(connectCalled, equals(true));
    });

    test('Adapter is build handler is called', () {
      expect(buildCalled, equals(true));
    });

    test('Adapter username is not `Bill`', () {
      expect(originalUser, isNotNull);
      expect(originalUser, isNot(equals('Bill')));
    });

    test('Adapter username is set to Bill', () {
      var adapter = Shellstone.adapters['mock'];
      expect(adapter.user, equals('Bill'));
    });
  });
}

var originalUser;
var configureCalled;
var connectCalled;
var buildCalled;

@DBAdapter('mock')
class MongoAdapter {
  @configure setCredentials(adapter) {
    if (originalUser == null) originalUser = adapter.user;

    configureCalled = true;

    adapter.user = 'Bill';
    adapter.password = 'Wow';
  }
  @connect createPool(adapter) { connectCalled = true; }
  @build createTables(adapter) { buildCalled = true; }
  @disconnect @error cleanup(adapter) {}
}
