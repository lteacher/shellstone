import 'dart:mirrors';
import 'package:test/test.dart';
import 'package:shellstone/shellstone.dart';
import '../test_setups.dart';

// TODO: Is this suite of tests really required? The metadata set seems more
// useful?>
main() {
  setUpAll(() async {
    // Start shellstone to setup any annotations
    await strapIn();
  });
  group('Annotations', () {
    test('@Model(name) can set the resource for the model', () {
      expect(model.name,equals('person'));
    });

    test('@Model(source:String) can set the connection for the model', () {
      expect(model.source,equals('mongo'));
    });

    test('@Attr(type:String) sets an attribute type', () {
      expect(attr('id').type,equals('integer'));
    });

    test('@Attr(primaryKey:bool) sets an attribute primaryKey', () {
      expect(attr('id').primaryKey,equals(true));
    });

    test('@Attr(column:String) sets an attribute column', () {
      expect(attr('firstName').column,equals('FirstName'));
    });

    test('@Adapter(name) sets the adapter name', () {
      expect(dbAdapter.name,equals('mongo'));
    });
  });
}

// Get the user model reflectee
dynamic get model => reflectClass(Person).metadata.first.reflectee;
dynamic attr(name) {
  var att = reflectClass(Person).declarations[new Symbol(name)]; //metadata.first.reflectee;
  return att.metadata.first.reflectee;
}
dynamic get dbAdapter => reflectClass(CustomMongoAdapter).metadata.first.reflectee;
