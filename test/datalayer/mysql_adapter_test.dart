import 'package:test/test.dart';
import 'dart:async';
import 'package:shellstone/shellstone.dart';
import '../test_setups.dart';

main() {
  setUpAll(() async {
    // Start shellstone to setup any annotations
    await strapIn();
  });

  tearDownAll(() async {
    await shutDown();
  });

  group('Mysql Adapter', () {
    test('Model.find(name) can be executed but returns nothing', () async {
      expect(await Model.find('MysqlUser').run(), equals(null));
    });

    test('Model.insertFrom(user) can insert a new user', () async {
      var user = new MysqlUser()
        ..username = 'jjon'
        ..password = '12345'
        ..firstName = 'Jim'
        ..lastName = 'Jones';

      var insertIds = await Model.insertFrom(user).run();
      expect(insertIds.first, equals(1));
      expect(user.id, equals(1));
    });

    test('Model.insertFrom([users]) can insert multiple users', () async {
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

    test('Model.insert(User,values) can insert a new user', () async {
      var map = {
        'username': 'kjoe',
        'password': '909898',
        'firstName': 'Kelly',
        'lastName': 'Jones'
      };

      var insertIds = await Model.insert(MysqlUser,map).run();
      expect(insertIds.first, equals(4));
    });

    test('Model.insert(User,[values]) can insert a new user', () async {
      var arr = [{
        'username': 'eone',
        'password': '878232',
        'firstName': 'Emily',
        'lastName': 'Norma'
      },
      {
        'username': 'blaerg',
        'password': '134234',
        'firstName': 'Belinda',
        'lastName': 'Laerga'
      }
    ];

      var insertIds = await Model.insert(MysqlUser,arr).run();
      expect(insertIds, equals([5,6]));
    });

    test('Model.find(`User`).where(f).eq(v) can find the correct user',
        () async {
      MysqlUser user = await Model.find('MysqlUser').where('firstName').eq('Bill').run();
      expect(user.firstName, equals('Bill'));
    });

    test('Model.find(User).where(f).eq(v) can find the correct user',
        () async {
      MysqlUser user = await Model.find(MysqlUser).where('firstName').eq('Emily').run();
      expect(user.username, equals('eone'));
    });

    test('Model.find(`User`).where([f]).eq([v]) can find the correct user',
        () async {
      MysqlUser user = await Model
          .find('MysqlUser')
          .where(['lastName', 'username']).eq(['Jones', 'cchill']).run();
      expect(user.firstName, equals('Charles'));
    });

    test('Model.findAll(`User`).where(f).eq(v) finds the correct two users',
        () async {
      List results =
          await Model.findAll('MysqlUser').where('lastName').eq('Jones').run();
      List users = [];
      await results.forEach((user) {
        users.add(user.firstName);
      });

      expect(users, equals(['Jim', 'Charles', 'Kelly']));
    });

    test('Model.findAll(`User`).where(f).ne(v) finds the correct user',
        () async {
      List results =
          await Model.findAll('MysqlUser').where('lastName').ne('Jones').run();
      List users = [];
      await results.forEach((user) {
        users.add(user.firstName);
      });

      expect(users, equals(['Bill', 'Emily', 'Belinda']));
    });

    test('Model.findAll(`User`).where(f).gt(v) finds the correct single user',
        () async {
      List results = await Model.findAll('MysqlUser').where('id').gt(5).run();
      List users = [];
      await results.forEach((user) {
        users.add(user.firstName);
      });

      expect(users, equals(['Belinda']));
    });

    test('Model.findAll(`User`).where(f).ge(v) finds the correct two users',
        () async {
      List results = await Model.findAll('MysqlUser').where('id').ge(5).run();
      List users = [];
      await results.forEach((user) {
        users.add(user.firstName);
      });

      expect(users, equals(['Emily', 'Belinda']));
    });

    test('Model.findAll(`User`).where(f).lt(v) finds the correct single user',
        () async {
      List results = await Model.findAll('MysqlUser').where('id').lt(2).run();
      List users = [];
      await results.forEach((user) {
        users.add(user.firstName);
      });

      expect(users, equals(['Jim']));
    });

    test('Model.findAll(`User`).where(f).le(v) finds the correct two users',
        () async {
      List results = await Model.findAll('MysqlUser').where('id').le(2).run();
      List users = [];
      await results.forEach((user) {
        users.add(user.firstName);
      });

      expect(users, equals(['Jim', 'Bill']));
    });

    test(
        'Model.findAll(`User`).where(f).eq(v).or(f).eq(v) finds the correct two users',
        () async {
      List results = await Model
          .findAll('MysqlUser')
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
      List results = await Model
          .findAll('MysqlUser')
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
      List results = await Model
          .findAll('MysqlUser')
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
      List results =
          await Model.findAll('MysqlUser').where('id').gt(1).and('id').lt(3).run();
      List users = [];
      await results.forEach((user) {
        users.add(user.firstName);
      });

      expect(users, equals(['Bill']));
    });

    test('Model.get(`User`).id(f) returns the correct user', () async {
      MysqlUser user = await Model.get('MysqlUser').id(2).run();

      expect(user.firstName, equals('Bill'));
    });

    test('Model.find(`User`).filter(user) returns the correct user', () async {
      MysqlUser user = await Model
          .find('MysqlUser')
          .filter((user) => user.firstName == 'Bill')
          .run();
      expect(user.firstName, equals('Bill'));
    });

    test('Model.findAll(`User`).filter(user) returns the correct users',
        () async {
      List results = await Model
          .findAll('MysqlUser')
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
          await Model.find('MysqlUser').filter((user) => true == false).run();
      expect(user, equals(null));
    });

    test('Model.findAll(`User`).filter(user) returns the empty set', () async {
      List results =
          await Model.findAll('MysqlUser').filter((user) => true == false).run();
      List users = [];
      await results.forEach((user) {
        users.add(user.firstName);
      });
      expect(users, equals([]));
    });

    test('Model.updateFrom(user) can modify an entity', () async {
      MysqlUser user = await Model.get('MysqlUser').id(1).run();

      user.firstName = 'Jane';
      user.lastName = 'Doe';
      var id = await Model.updateFrom(user).run();
      user = await Model.get('MysqlUser').id(1).run();

      expect(id, equals(1));
      expect([user.firstName,user.lastName],equals(['Jane','Doe']));
    });

    test('Model.updateFrom([user]) can modify multiple entities', () async {
      MysqlUser u1 = await Model.get('MysqlUser').id(2).run();
      MysqlUser u2 = await Model.get('MysqlUser').id(3).run();

      u1.firstName = 'Sam';
      u2.firstName = 'Clint';
      var id = await Model.updateFrom([u1,u2]).run();
      u1 = await Model.get('MysqlUser').id(2).run();
      u2 = await Model.get('MysqlUser').id(3).run();

      expect(id, equals(2));
      expect([u1.firstName,u2.firstName],equals(['Sam','Clint']));
    });

    test('Model.update(User,values) can modify an entity', () async {
      await Model.update(MysqlUser,{'username':'zeal'}).where('firstName').eq('Belinda').run();
      MysqlUser user = await Model.get('MysqlUser').id(6).run();

      expect([user.username,user.firstName],equals(['zeal','Belinda']));
    });

    test('Model.update(User,values) can modify many entities', () async {
      await Model.update(MysqlUser,{'lastName':'Smith'}).where('lastName').eq('Jones').run();

      List results =
          await Model.findAll('MysqlUser').filter((user) => user.lastName == 'Smith').run();
      List users = [];
      await results.forEach((user) {
        users.add(user.firstName);
      });

      expect(users,equals(['Clint','Kelly']));
    });

    test('Model.removeFrom(user) removes the given entity', () async {
      MysqlUser user = new MysqlUser()..id = 1;
      var id = await Model.removeFrom(user).run();
      user = await Model.get('MysqlUser').id(1).run();
      expect(id, equals(1));
      expect(user, equals(null));
    });

    test('Model.removeFrom([users]) removes the given entities', () async {
      List users = []..add(new MysqlUser()..id = 2)..add(new MysqlUser()..id = 3);
      var id = await Model.removeFrom(users).run();
      MysqlUser u1 = await Model.get('MysqlUser').id(2).run();
      MysqlUser u2 = await Model.get('MysqlUser').id(3).run();
      expect(id, equals(2));
      expect(u1, equals(null));
      expect(u2, equals(null));
    });

    test('Model.remove(User).where() removes the given entities', () async {
      var id = await Model
          .remove(MysqlUser)
          .where('firstName')
          .eq('Belinda')
          .or('firstName')
          .eq('Kelly')
          .run();
      MysqlUser u1 = await Model.get('MysqlUser').id(4).run();
      MysqlUser u2 = await Model.get('MysqlUser').id(6).run();
      expect(id, equals(2));
      expect(u1, equals(null));
      expect(u2, equals(null));
    });
  });
}
