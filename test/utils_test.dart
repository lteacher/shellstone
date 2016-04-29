import 'package:test/test.dart';
import 'package:shellstone/shellstone.dart';
import 'test_setups.dart';

main() {
  setUp(() {
    // Start shellstone to setup any annotations
    strapIn();
  });

  group('Builders', () {
    test('EntityBuilder.create(name) instantiates a Model entity', () {
      expect(EntityBuilder.create('User'), new isInstanceOf<User>());
    });

    test('EntityBuilder.create(name,values) instantiates a Model entity with given values', () {
      User user = EntityBuilder.create('User',{
        const Symbol('id'):00001,
        const Symbol('username'):'megacool',
        const Symbol('password'):'12345',
      });

      expect(user.id, equals(00001));
      expect(user.username, equals('megacool'));
      expect(user.password, equals('12345'));
    });

    test('EntityWrapper.wrap converts a type to its meta annotated', () {
      Person person = new Person()..firstName = 'Bill'
                                  ..lastName = 'Smith'
                                  ..age = '100';

      var map = new EntityWrapper(entity: person).wrap();
      expect(map['FirstName'],equals('Bill'));
      expect(map['LastName'],equals('Smith'));
      expect(map['Age'],equals(100));
    });

    test('EntityWrapper.unwrap converts a map into a object', () {
      Map map = {
        'FirstName':'Bill',
        'LastName':'Smith',
        'Age':100
      };

      Person person = new EntityWrapper(name: 'Person').unwrap(map);

      expect(person.firstName,equals('Bill'));
      expect(person.lastName,equals('Smith'));
      expect(person.age,equals('100'));
    });
  });
}
