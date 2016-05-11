import 'package:test/test.dart';
import 'package:shellstone/shellstone.dart';

main() {
  setUp(() {
    // Start shellstone to setup any annotations
    strapIn();
  });
  group('Schemas', () {
    test('Schema is loaded for NewUser', () {
      expect(Schema.get('NewUser'), new isInstanceOf<Schema>());
    });

    test('Schema resource is `user`', () {
      expect(Schema.get('NewUser').resource, equals('user'));
    });

    test('Schema source is defaulted to `mysql`', () {
      expect(Schema.get('NewUser').source, equals('mysql'));
    });

    test('Schema migration is `drop`', () {
      expect(Schema.get('NewUser').migration, equals('drop'));
    });

    test('Schema knows the correct primary key', () {
      expect(Schema.get('NewUser').primaryKey.name, equals('id'));
    });

    test('Schema knows the indexes', () {
      expect(Schema.get('NewUser').indexes['ugly'], equals(isNotNull));
    });

    test('Schema can find fields by column', () {
      expect(Schema.get('NewUser').getColumn('userName').name, equals('username'));
      expect(Schema.get('NewUser').getColumn('passWord').name, equals('password'));
    });

    test('Schema has field types correct', () {
      expect(Schema.get('NewUser').getField('id').type, equals('integer'));
      expect(Schema.get('NewUser').getField('username').type, equals('string'));
      expect(Schema.get('NewUser').getField('ugly').type, equals('string'));
    });

    test('Schema field for ugly is converted correct', () {
      expect(Schema.get('NewUser').getField('ugly').autoIncr, equals(true));
      expect(Schema.get('NewUser').getField('ugly').column, equals('uglyThing'));
      expect(Schema.get('NewUser').getField('ugly').unique, equals(true));
    });
  });
}

@Model(name: 'user', migration: 'drop')
class NewUser {

  @Attr(type: 'integer', primaryKey: true)
  String id;

  @Attr(column: 'userName')
  String username;

  @Attr(column: 'passWord')
  String password;

  @Attr(
      column: 'uglyThing',
      type: 'string',
      unique: true,
      index: true,
      autoIncr: true)
  int ugly;
}
