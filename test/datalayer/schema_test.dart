import 'package:test/test.dart';
import 'package:shellstone/shellstone.dart';

main() {
  setUpAll(() async {
    // Start shellstone to setup any annotations
    await strapIn();
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
      expect(Schema.get('NewUser').getField('ugly').column, equals('uglyThing'));
      expect(Schema.get('NewUser').getField('ugly').unique, equals(true));
    });

    test('Schema relation can be retrieved', () {
      expect(Schema.get('Person').getRelation('addresses'), new isInstanceOf<SchemaRelation>());
    });

    test('Schema relation knows all the attributes', () {
      SchemaRelation relation = Schema.get('Person').getRelation('addresses');
      expect(relation.name, equals('addresses'));
      expect(relation.by, equals('externalId'));
      expect(relation.as, equals('legacy_person_id'));
    });

    test('Schema relation infers `by` and `as` from Model', () {
      SchemaRelation relation = Schema.get('Business').getRelation('addresses');
      expect(relation.by, equals('id'));
      expect(relation.as, equals('business_id'));
    });

    test('Schema relation knows if it is a many or single association', () {
      SchemaRelation relation = Schema.get('Business').getRelation('addresses');
      expect(relation.isCollection, equals(true));
    });

    test('Schema with relation has derived field', () {
      var schema = Schema.get('Address');
      var field = schema.getDerived('business_id');
      expect(field, new isInstanceOf<SchemaField>());
      expect(field.primaryKey, equals(false));
      expect(field.index, equals(true));
      expect(field.column, equals(field.name));
      expect(field.type, equals('integer'));
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
      index: true)
  int ugly;
}
