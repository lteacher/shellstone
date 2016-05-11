import 'dart:async';
import 'package:shellstone/shellstone.dart';

@Model(name: 'useracc', source: 'postgres')
class PostgresUser {
  @Attr(type: 'integer', primaryKey: true)
  int id;
  @Attr(type: 'string')
  String username;
  @Attr(type: 'string')
  String password;
  @Attr(type: 'string')
  String firstName;
  @Attr(type: 'string')
  String lastName;
}

@Model(name: 'orders', source: 'postgres')
class Order {
  @Attr(type: 'integer', primaryKey: true)
  int id;
  @Attr()
  String description;
  @Attr()
  double totalCost;
}

main() async {
  await strapIn();

  var user = new PostgresUser()
    ..username = 'jjon'
    ..password = '12345'
    ..firstName = 'Jim'
    ..lastName = 'Jones';

  var insertIds = await Model.insertFrom(user).run();

  print(insertIds);
}

// Javascript Examples
// User.find({ where: { name: 'foo' }, skip: 20, limit: 10, sort: 'name DESC' });
// User.find({ name: { '!' : ['Walter', 'Skyler'] }});

// [Expected] Shellstone Examples
// Model.find('User').where(['name']).eq('foo').skip(20).limit(10).sort(['name'],Desc).run();
// Model.find('User').where(['name']).ne(['Walter','Skyler']).run();
