import 'package:test/test.dart';
import 'package:shellstone/shellstone.dart';
import 'test_setups.dart';

main() {
  setUp(() {
    // Start shellstone to setup any annotations
    strapIn();
  });
  group('Mysql Adapter', () {
    // test('Model.find(name) can be executed but returns nothing', () async {
    //   expect(await Model.find('User').run(),equals(null));
    // });

    // test('Model.find(name) can be executed but returns nothing', () async {
    //   expect(await Model.find('user').run(),equals(null));
    // });
  });
}

@Hook(Adapter.configure)
setCredentials(event) {
  var conn = event.data;

  conn.user = 'root';
  conn.password = 'root';
  conn.host = '127.0.0.1';
  conn.db = 'test';
}
