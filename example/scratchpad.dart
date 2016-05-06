import 'dart:async';
import '../lib/shellstone.dart';
// import 'package:sqljocky/sqljocky.dart';

@Model('user', source: 'mysql')
class User {
  @Attr()
  String id;
  @Attr()
  String firstName;
  @Attr()
  String lastName;
  @Attr()
  String username;
  @Attr()
  String password;
}

@Hook(Adapter.configure)
setCredentials(event) {
  var user = new User()..firstName = 'Bill';

var map = new EntityWrapper(user).wrap();
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
