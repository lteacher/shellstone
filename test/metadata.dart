import 'package:test/test.dart';
import '../lib/shellstone.dart';
import 'setups.dart';

main() {
  setUp(() {
    // Start shellstone to setup any annotations
    Shellstone.start();
  });

  group('Metadata', () {
    test('Metadata.proxy(name) returns a ModelProxy object', () {
      expect(Metadata.proxy('User'), new isInstanceOf<ModelProxy>());
    });

    test('Metadata.model(name) has a reference to the Model class', () {
      expect(Metadata.model('User'), new isInstanceOf<Model>());
    });

    test('Model.indentity can be retrieved', () {
      expect(model.identity, equals('user'));
    });

    test('Model.autoCreatedAt can be retrieved', () {
      expect(model.autoCreatedAt, equals(true));
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

    // Cant get this one to match for some reason
    // test('Unknown Model type throws error', () {
    //   expect(Metadata.name(const Symbol('Explode')), throws);
    // });
  });
}

get model =>  Metadata.model('User');
attr(name) => Metadata.attr('User')[name];
