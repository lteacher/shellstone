import 'package:test/test.dart';
import 'dart:async';
import 'package:shellstone/shellstone.dart';
import '../test_setups.dart';

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
      var user = new MysqlUser()
        ..username = 'jjon'
        ..password = '12345'
        ..firstName = 'Jim'
        ..lastName = 'Jones';

      var insertIds = await Model.insertFrom(user).run();
      expect(insertIds.first, equals(1));
      expect(user.id, equals(1));
    });

    test('Model.insert([users]) can insert multiple users', () async {
      var user1 = new MysqlUser()
        ..username = 'bbill'
        ..password = '54321'
        ..firstName = 'Bill'
        ..lastName = 'Bob';

      var user2 = new MysqlUser()
        ..username = 'cchill'
        ..password = '6789'
        ..firstName = 'Charles'
        ..lastName = 'Jones';
      var users = []..add(user1)..add(user2);

      var insertIds = await Model.insertFrom(users).run();
      expect(insertIds, equals([2, 3]));
    });

    test('Model.find(`User`).where(f).eq(v) can find the correct user',
        () async {
      MysqlUser user = await Model.find('User').where('firstName').eq('Bill').run();
      expect(user.firstName, equals('Bill'));
    });

    test('Model.find(`User`).where([f]).eq([v]) can find the correct user',
        () async {
      MysqlUser user = await Model
          .find('User')
          .where(['lastName', 'username']).eq(['Jones', 'cchill']).run();
      expect(user.firstName, equals('Charles'));
    });

    test('Model.findAll(`User`).where(f).eq(v) finds the correct two users',
        () async {
      Stream results =
          await Model.findAll('User').where('lastName').eq('Jones').run();
      List users = [];
      await results.forEach((user) {
        users.add(user.firstName);
      });

      expect(users, equals(['Jim', 'Charles']));
    });

    test('Model.findAll(`User`).where(f).ne(v) finds the correct user',
        () async {
      Stream results =
          await Model.findAll('User').where('lastName').ne('Jones').run();
      List users = [];
      await results.forEach((user) {
        users.add(user.firstName);
      });

      expect(users, equals(['Bill']));
    });

    test('Model.findAll(`User`).where(f).gt(v) finds the correct single user',
        () async {
      Stream results = await Model.findAll('User').where('id').gt(2).run();
      List users = [];
      await results.forEach((user) {
        users.add(user.firstName);
      });

      expect(users, equals(['Charles']));
    });

    test('Model.findAll(`User`).where(f).ge(v) finds the correct two users',
        () async {
      Stream results = await Model.findAll('User').where('id').ge(2).run();
      List users = [];
      await results.forEach((user) {
        users.add(user.firstName);
      });

      expect(users, equals(['Bill', 'Charles']));
    });

    test('Model.findAll(`User`).where(f).lt(v) finds the correct single user',
        () async {
      Stream results = await Model.findAll('User').where('id').lt(2).run();
      List users = [];
      await results.forEach((user) {
        users.add(user.firstName);
      });

      expect(users, equals(['Jim']));
    });

    test('Model.findAll(`User`).where(f).le(v) finds the correct two users',
        () async {
      Stream results = await Model.findAll('User').where('id').le(2).run();
      List users = [];
      await results.forEach((user) {
        users.add(user.firstName);
      });

      expect(users, equals(['Jim', 'Bill']));
    });

    test(
        'Model.findAll(`User`).where(f).eq(v).or(f).eq(v) finds the correct two users',
        () async {
      Stream results = await Model
          .findAll('User')
          .where('id')
          .eq(1)
          .or('firstName')
          .eq('Charles')
          .run();
      List users = [];
      await results.forEach((user) {
        users.add(user.firstName);
      });

      expect(users, equals(['Jim', 'Charles']));
    });

    test(
        'Model.findAll(`User`).where(f).eq(v).and(f).eq(v) finds the correct users',
        () async {
      Stream results = await Model
          .findAll('User')
          .where('lastName')
          .eq('Jones')
          .and('firstName')
          .eq('Charles')
          .run();
      List users = [];
      await results.forEach((user) {
        users.add(user.firstName);
      });

      expect(users, equals(['Charles']));
    });

    test(
        'Model.findAll(`User`).where(f).complex A... finds the correct two users',
        () async {
      Stream results = await Model
          .findAll('User')
          .where('lastName')
          .eq('Jones')
          .and('id')
          .eq(1)
          .or('id')
          .eq(3)
          .run();
      List users = [];
      await results.forEach((user) {
        users.add(user.firstName);
      });

      expect(users, equals(['Jim', 'Charles']));
    });

    test(
        'Model.findAll(`User`).where(f).complex B... finds the correct two users',
        () async {
      Stream results =
          await Model.findAll('User').where('id').gt(1).and('id').lt(3).run();
      List users = [];
      await results.forEach((user) {
        users.add(user.firstName);
      });

      expect(users, equals(['Bill']));
    });

    test('Model.get(`User`).id(f) returns the correct user', () async {
      MysqlUser user = await Model.get('User').id(2).run();

      expect(user.firstName, equals('Bill'));
    });

    test('Model.find(`User`).filter(user) returns the correct user', () async {
      MysqlUser user = await Model
          .find('User')
          .filter((user) => user.firstName == 'Bill')
          .run();
      expect(user.firstName, equals('Bill'));
    });

    test('Model.findAll(`User`).filter(user) returns the correct users',
        () async {
      Stream results = await Model
          .findAll('User')
          .filter(
              (user) => user.firstName == 'Jim' || user.firstName == 'Charles')
          .run();
      List users = [];
      await results.forEach((user) {
        users.add(user.firstName);
      });
      expect(users, equals(['Jim', 'Charles']));
    });

    test('Model.find(`User`).filter(user) returns null', () async {
      MysqlUser user =
          await Model.find('User').filter((user) => true == false).run();
      expect(user, equals(null));
    });

    test('Model.findAll(`User`).filter(user) returns the empty set', () async {
      Stream results =
          await Model.findAll('User').filter((user) => true == false).run();
      List users = [];
      await results.forEach((user) {
        users.add(user.firstName);
      });
      expect(users, equals([]));
    });

    test('Model.update(user) can modify an entity', () async {
      MysqlUser user = await Model.get('User').id(1).run();

      user.firstName = 'Jane';
      user.lastName = 'Doe';
      var id = await Model.updateFrom(user).run();
      user = await Model.get('User').id(1).run();

      expect(id, equals(1));
      expect([user.firstName,user.lastName],equals(['Jane','Doe']));
    });

    test('Model.update([user]) can modify multiple entities', () async {
      MysqlUser u1 = await Model.get('User').id(2).run();
      MysqlUser u2 = await Model.get('User').id(3).run();

      u1.firstName = 'Sam';
      u2.firstName = 'Clint';
      var id = await Model.updateFrom([u1,u2]).run();
      u1 = await Model.get('User').id(2).run();
      u2 = await Model.get('User').id(3).run();

      expect(id, equals(2));
      expect([u1.firstName,u2.firstName],equals(['Sam','Clint']));
    });

    test('Model.remove(user) removes the given entity', () async {
      MysqlUser user = new MysqlUser()..id = 1;
      var id = await Model.removeFrom(user).run();
      user = await Model.get('User').id(1).run();
      expect(id, equals(1));
      expect(user, equals(null));
    });

    test('Model.removeAll([users]) removes the given entities', () async {
      List users = []..add(new MysqlUser()..id = 2)..add(new MysqlUser()..id = 3);
      var id = await Model.removeFrom(users).run();
      MysqlUser u1 = await Model.get('User').id(2).run();
      MysqlUser u2 = await Model.get('User').id(3).run();
      expect(id, equals(2));
      expect(u1, equals(null));
      expect(u2, equals(null));
    });
  });
}
