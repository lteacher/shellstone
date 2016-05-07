import 'package:shellstone/shellstone.dart';

@Hook(Adapter.configure)
setCredentials(event) {
  var conn = event.data;

  conn.user = 'root';
  conn.password = 'root';
  conn.host = '127.0.0.1';
  conn.db = 'test';
}

@Model('user')
class User {
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
