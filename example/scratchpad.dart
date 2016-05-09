import 'dart:async';
import 'package:shellstone/shellstone.dart';

@Model('useracc', source: 'postgres')
class PostgresUser {
  @Attr(type: 'integer', primaryKey: true) int id;
  @Attr(type: 'string') String username;
  @Attr(type: 'string') String password;
  @Attr(type: 'string') String firstName;
  @Attr(type: 'string') String lastName;
}

@Model('user')
class MysqlUser {
  @Attr(type: 'integer', primaryKey: true) int id;
  @Attr(type: 'string') String username;
  @Attr(type: 'string') String password;
  @Attr(type: 'string') String firstName;
  @Attr(type: 'string') String lastName;
}
main() async {
  await strapIn();

}

// Javascript Examples
// User.find({ where: { name: 'foo' }, skip: 20, limit: 10, sort: 'name DESC' });
// User.find({ name: { '!' : ['Walter', 'Skyler'] }});

// [Expected] Shellstone Examples
// Model.find('User').where(['name']).eq('foo').skip(20).limit(10).sort(['name'],Desc).run();
// Model.find('User').where(['name']).ne(['Walter','Skyler']).run();
