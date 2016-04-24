import 'dart:async';
import '../lib/shellstone.dart';

@Model()
class User {
  @Attr(type: 'string') String name;
}

main() {
  Future result = Model.find('User').where(['name']).eq('Bill').run();

  result.then((List list) {
    list.forEach((entry) {
      print('Operator: ${entry.op} Values: ${entry.values}');
    });
  });
}


// Waterline Examples
// User.find({ where: { name: 'foo' }, skip: 20, limit: 10, sort: 'name DESC' });
// User.find({ name: { '!' : ['Walter', 'Skyler'] }});


// [Expected] Shellstone Examples
// Model.find('User').where(['name']).eq('foo').skip(20).limit(10).sort(['name'],Desc).run();
// Model.find('User').where(['name']).ne(['Walter','Skyler']).run();
