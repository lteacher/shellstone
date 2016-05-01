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

main() async {
  strapIn();

  Stream results = await Model.findAll('User').where('id').le(3).run();
  results.forEach((user) {
    print(user.firstName);
  });


  // await adapters('mysql').disconnect();

  // User user = new User();
  // user.firstName = 'Jimmy';
  // user.lastName = 'Jones';
  // user.username = 'jswizzle@g.com';
  // user.password = '123456';

  // Stream res = await Model.insert(user).run();
  //
  // res.forEach((a) {
  //   print(a);
  // });
  //
  //
  // // Model.insertAll([user]).run();
  //
  // print(user != null ? user.firstName : 'No results');
}

// Javascript Examples
// User.find({ where: { name: 'foo' }, skip: 20, limit: 10, sort: 'name DESC' });
// User.find({ name: { '!' : ['Walter', 'Skyler'] }});

// [Expected] Shellstone Examples
// Model.find('User').where(['name']).eq('foo').skip(20).limit(10).sort(['name'],Desc).run();
// Model.find('User').where(['name']).ne(['Walter','Skyler']).run();
