import 'dart:mirrors';
import 'package:test/test.dart';
import 'setups.dart';

main() {
  group('Annotations', () {
    test('@Model(identity:String) can set the identity for the model', () {
      expect(model.identity,equals('user'));
    });

    test('@Model(connection:String) can set the connection for the model', () {
      expect(model.connection,equals('mongodb'));
    });

    test('@Model(autoCreatedAt:bool) sets the auto created option', () {
      expect(model.autoCreatedAt,equals(true));
    });

    test('@Model(autoUpdatedAt:bool) sets the auto updated option', () {
      expect(model.autoUpdatedAt,equals(true));
    });

    test('@Attr(type:String) sets an attribute type', () {
      expect(attr('id').type,equals('integer'));
    });

    test('@Attr(primaryKey:bool) sets an attribute primaryKey', () {
      expect(attr('id').primaryKey,equals(true));
    });

    test('@Attr(column:String) sets an attribute column', () {
      expect(attr('username').column,equals('user_name'));
    });
  });
}

// Get the user model reflectee
dynamic get model => reflectClass(User).metadata.first.reflectee;
dynamic attr(name) {
  var att = reflectClass(User).declarations[new Symbol(name)]; //metadata.first.reflectee;
  return att.metadata.first.reflectee;
}
