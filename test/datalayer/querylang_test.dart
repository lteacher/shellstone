import 'package:test/test.dart';
import 'package:shellstone/shellstone.dart';
import '../test_setups.dart';

main() {
  setUp(() {
    // Start shellstone to setup any annotations
    strapIn();
  });
  group('Query Language', () {
    test('Model.get(model:String) returns an Identifier', () {
      expect(Model.get('User'),new isInstanceOf<Identifier>());
    });

    test('Model.get(model:String).id(dynamic) returns a Runnable', () {
      expect(Model.get('User').id(123),new isInstanceOf<Runnable>());
    });

    test('Model.insert(name,values) returns a Runnable', () {
      expect(Model.insert('User',{'firstName':'Bill'}),new isInstanceOf<Runnable>());
    });

    test('Model.insertFrom(user) returns a Runnable', () {
      expect(Model.insertFrom(new User()),new isInstanceOf<Runnable>());
    });

    test('Model.update(name,values) returns a SingleResultQuery', () {
      expect(Model.update('User',{'firstName':'Bill'}),new isInstanceOf<SingleResultQuery>());
    });

    test('Model.updateFrom(user) returns a Runnable', () {
      expect(Model.updateFrom(new User()),new isInstanceOf<Runnable>());
    });

    test('Model.remove(name) returns a SingleResultQuery', () {
      expect(Model.remove('User'),new isInstanceOf<SingleResultQuery>());
    });

    test('Model.removeFrom(user) returns a Runnable', () {
      expect(Model.removeFrom(new User()),new isInstanceOf<Runnable>());
    });

    test('Model.find(model:String) Returns a SingleResultQuery', () {
      expect(Model.find('User'),new isInstanceOf<SingleResultQuery>());
    });

    test('Model.find(Type model) Returns a SingleResultQuery', () {
      expect(Model.find(User),new isInstanceOf<SingleResultQuery>());
    });

    test('Model.findAll(model:String) Returns a MultipleResultQuery', () {
      expect(Model.findAll('User'),new isInstanceOf<MultipleResultQuery>());
    });

    test('Model.findAll(Type model) Returns a MultipleResultQuery', () {
      expect(Model.findAll(User),new isInstanceOf<MultipleResultQuery>());
    });

    test('Model.find(model:String).where(columns) returns a Filter and !Runnable', () {
      expect(Model.find('User').where(['firstName']),allOf([
        new isInstanceOf<Filter>(),
        isNot(new isInstanceOf<Runnable>())
      ]));
    });

    test('Model.find(model:String).where(column).eq(values) returns Selector or Modifier + Runnable', () {
      expect(Model.find('User').where('firstName').eq('Bill'),allOf([
        new isInstanceOf<SingleResultSelector>(),
        new isInstanceOf<SingleResultModifier>(),
        new isInstanceOf<Runnable>(),
      ]));
    });

    test('Model.find(model:String).where(column).eq(values).limit(n) returns only a Modifier + Runnable', () {
      expect(Model.find('User').where(['firstName']).eq(['Bill']).limit(9),allOf([
        new isInstanceOf<Modifier>(),
        new isInstanceOf<Runnable>(),
        isNot(new isInstanceOf<Selector>()),
        isNot(new isInstanceOf<Filter>()),
      ]));
    });

    test('Model.findAll(model:String) Returns a MultipleResultQuery', () {
      expect(Model.findAll('User'),new isInstanceOf<MultipleResultQuery>());
    });
  });
}
