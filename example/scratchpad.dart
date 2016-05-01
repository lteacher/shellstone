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

@Hook.pre(Adapter.configure)
setCredentials(event) {
  // print(event.data);
  // event.data.user = 'hugodd';
}

@Listen.pre(Adapter.configure)
logBeforeConfig(event) {
  print('Doing config');
}

@Listen.post(Adapter.configure)
logAfterConfig(event) {
  print('Doing after');
}

// @Adapter('mysql')
// class CustomMysqlAdapter extends DatabaseAdapter {
//
//   get name => 'mysql';
//   get driver { }
//
//   configure() {}
//   connect() {}
//   build() {}
//   disconnect() {}
//   execute(chain) {}
// }

main() async {
  strapIn();

}

// Javascript Examples
// User.find({ where: { name: 'foo' }, skip: 20, limit: 10, sort: 'name DESC' });
// User.find({ name: { '!' : ['Walter', 'Skyler'] }});

// [Expected] Shellstone Examples
// Model.find('User').where(['name']).eq('foo').skip(20).limit(10).sort(['name'],Desc).run();
// Model.find('User').where(['name']).ne(['Walter','Skyler']).run();
