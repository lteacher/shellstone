import 'package:test/test.dart';
import '../lib/shellstone.dart';

main() {
  setUp(() {
    // Start shellstone to setup any annotations
    Shellstone.start();
  });

  group('Metadata', () {
    test('new Metadata().model(name) returns a ModelProxy object', () {
      expect(proxy, new isInstanceOf<ModelProxy>());
    });

    test('new ModelProxy.model has a reference to the Model class', () {
      expect(model, new isInstanceOf<Model>());
    });

    test('Model.indentity can be retrieved', () {
      expect(model.identity, equals('user'));
    });

    test('Model.autoCreatedAt can be retrieved', () {
      expect(model.autoCreatedAt, equals(true));
    });

    test('ModelProxy attributes return an Attr class', () {
      expect(attr('username'), new isInstanceOf<Attr>());
    });

    test('Attr types can be retrieved', () {
      expect(attr('username').type, equals('string'));
    });
  });
}

get proxy =>  new Metadata().model('User');
get model =>  proxy.model;
attr(name) => proxy.attributes[name];

@Model(identity: 'user', autoCreatedAt: true, autoUpdatedAt: true)
class User {
  @Attr(type: 'integer') int id;
  @Attr(type: 'string') String username;
  @Attr(type: 'string') String password;
}
