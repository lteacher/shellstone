// import 'package:matcher/matcher.dart';
import 'package:test/test.dart';
import '../lib/shellstone.dart';

main() {
  group('Query Language', () {
    test('Model.get(model:String) returns an Identifier', () {
      expect(Model.get('User'),new isInstanceOf<Identifier>());
    });

    test('Model.get(model:String).id(dynamic) returns a Runnable', () {
      expect(Model.get('User').id(123),new isInstanceOf<Runnable>());
    });

    test('Model.find(model:String) Returns a Query', () {
      expect(Model.find('User'),new isInstanceOf<Query>());
    });

    test('Model.findAll(model:String) Returns a Query', () {
      expect(Model.findAll('User'),new isInstanceOf<Query>());
    });

    test('Model.find(model:String).where(columns) Returns Filterable & !Runnable', () {
      expect(Model.find('User').where(['firstName']),allOf([
        new isInstanceOf<Filterable>(),
        isNot(new isInstanceOf<Runnable>())
      ]));
    });

    test('Model.find(model:String).where(columns).eq(values) Returns Runnable, Selectable & !Filterable', () {
      expect(Model.find('User').where(['firstName']).eq('Bill'),allOf([
        new isInstanceOf<Runnable>(),
        new isInstanceOf<Selectable>(),
        isNot(new isInstanceOf<Filterable>())
      ]));
    });

    test('Model.find(model:String).where(columns).eq(values).limit(n) Returns Runnable or Constrainable', () {
      expect(Model.find('User').where(['firstName']).eq('Bill').limit(10),allOf([
        new isInstanceOf<Runnable>(),
        new isInstanceOf<Constrainable>(),
        isNot(new isInstanceOf<Selectable>()),
        isNot(new isInstanceOf<Filterable>())
      ]));
    });

    // test('Model.insert(dynamic:Model) Returns a Query', () {
    //   expect(Model.insert('User'),new isInstanceOf<Query>());
    // });
    //
    // test('Model.insertAll(dynamic:Model) Returns a Query', () {
    //   expect(Model.insertAll('User'),new isInstanceOf<Query>());
    // });

  });
}
