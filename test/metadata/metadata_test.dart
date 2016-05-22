import 'package:test/test.dart';
import 'package:shellstone/shellstone.dart';
import '../test_setups.dart';

main() {
  setUpAll(() async {
    // Start shellstone to setup any annotations
    await strapIn();
  });

  group('Metadata', () {
    test('Metadata.proxy(name) returns a ModelProxy object', () {
      expect(Metadata.get(Model,'User'), new isInstanceOf<ModelMetadata>());
    });

    test('Metadata.model(name) has a reference to the Model class', () {
      expect(Metadata.model('User'), new isInstanceOf<Model>());
    });

    test('Model.name can be retrieved', () {
      expect(model.name, equals('user'));
    });

    test('Metadata.attr(name) returns an Attr class', () {
      expect(Metadata.attr('User')['username'], new isInstanceOf<Attr>());
    });

    test('Attr types can be retrieved', () {
      expect(Metadata.attr('User')['username'].type, equals('string'));
    });

    test('Model name can be determined by passing an entity type', () {
      var user = new User();
      expect(Metadata.name(user), equals('User'));
    });

    test('Model name can be determined by passing an entity List', () {
      List user = [new User()];
      expect(Metadata.name(user), equals('User'));
    });

    test('Unknown Model type throws error', () {
      expect(() => Metadata.name(const Symbol('Explode')), throwsA(new isInstanceOf<String>()));
    });

    test('Metadata.rel(name) returns a Rel class', () {
      expect(Metadata.rel('Person')['addresses'], new isInstanceOf<Rel>());
    });

    test('Rel model type can be retrieved', () {
      expect(Metadata.rel('Person')['addresses'].model, equals(Address));
    });

    test('Rel model type can be retrieved and inferred', () {
      expect(Metadata.rel('Business')['addresses'].model, equals(Address));
    });

    test('Rel members are captured', () {
      Rel rel = Metadata.rel('Person')['addresses'];
      expect(rel.by, equals('externalId'));
      expect(rel.as, equals('legacy_person_id'));
    });
  });
}

get model =>  Metadata.model('User');
attr(name) => Metadata.attr('User')[name];
