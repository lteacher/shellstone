import 'dart:async';
import '../lib/shellstone.dart';
// import 'package:sqljocky/sqljocky.dart';

@Model('User', dataSource: 'mysql', autoCreatedAt: true, autoUpdatedAt: true)
class User {
  @Attr() String id;
  @Attr() String firstName;
  @Attr() String lastName;
  @Attr() String username;
  @Attr() String password;
  @Attr() String email;
}

@Hook(Adapter.configure)
setCredentials(event) {
  // var conn = event.data;
  //
  // conn.user = 'root';
  // conn.password = 'root';
  // conn.host = '127.0.0.1';
  // conn.db = 'test';
  print('bam');
}

@Hook(Adapter.configure)
notSetCredentials(event) {
  print('pow');
}


main() async {
  await strapIn();

  var user = await Model.find('User').run();
}

// Javascript Examples
// User.find({ where: { name: 'foo' }, skip: 20, limit: 10, sort: 'name DESC' });
// User.find({ name: { '!' : ['Walter', 'Skyler'] }});

// [Expected] Shellstone Examples
// Model.find('User').where(['name']).eq('foo').skip(20).limit(10).sort(['name'],Desc).run();
// Model.find('User').where(['name']).ne(['Walter','Skyler']).run();
