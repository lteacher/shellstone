import 'package:test/test.dart';
import 'dart:async';
import 'package:shellstone/shellstone.dart';
import 'test_setups.dart';

main() {
  setUp(() {
    // Start shellstone to setup any annotations
    strapIn();
  });

  tearDown(() async {
    await adapters('mysql').disconnect();
  });

  group('Mysql Adapter', () {
    test('Model.find(name) can be executed but returns nothing', () async {
      expect(await Model.find('User').run(), equals(null));
    });

    test('Model.insert(user) can insert a new user', () async {
      var user = new User()
        ..username = 'jjon'
        ..password = '12345'
        ..firstName = 'Jim'
        ..lastName = 'Jones';

      var insertIds = await Model.insert(user).run();
      expect(insertIds.first, equals(1));
    });

    test('Model.insert([users]) can multiple users', () async {
      var user1 = new User()
        ..username = 'bbill'
        ..password = '54321'
        ..firstName = 'Bill'
        ..lastName = 'Bob';

      var user2 = new User()
        ..username = 'cchill'
        ..password = '6789'
        ..firstName = 'Charles'
        ..lastName = 'Jones';
      var users = []..add(user1)..add(user2);

      var insertIds = await Model.insertAll(users).run();
      expect(insertIds, equals([2,3]));
    });

    test('Model.find(`User`).where(f).eq(v) can find the correct user', () async {
      User user = await Model.find('User').where('firstName').eq('Bill').run();
      expect(user.firstName, equals('Bill'));
    });

    test('Model.find(`User`).where([f]).eq([v]) can find the correct user', () async {
      User user = await Model.find('User').where(['lastName','username']).eq(['Jones','cchill']).run();
      expect(user.firstName, equals('Charles'));
    });

    test('Model.findAll(`User`).where(f).eq(v) finds the correct two users', () async {
      Stream results = await Model.findAll('User').where('lastName').eq('Jones').run();
      List users = [];
      await results.forEach((user) {
        users.add(user.firstName);
      });

      expect(users, equals(['Jim','Charles']));
    });

    test('Model.findAll(`User`).where(f).ne(v) finds the correct two user', () async {
      Stream results = await Model.findAll('User').where('lastName').ne('Jones').run();
      List users = [];
      await results.forEach((user) {
        users.add(user.firstName);
      });

      expect(users, equals(['Bill']));
    });
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
