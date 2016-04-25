import '../lib/shellstone.dart';
import 'package:sqljocky/sqljocky.dart';
import 'dart:async';

@Model('User')
class User {
  @Attr(type: 'string', column: 'fullName') String name;
}

main() async {
  Shellstone.setup();

  Stream<Row> results = await Model.find('User').where(['username','password']).eq(['bill','12345']).run();

  print(results);

  results.forEach((row) {
    print(row[0]);
  });

  // User user = EntityBuilder.create('User',{const Symbol('name'):'Jimmah'});
  //
  // Map wrapped = Metadata.wrap(user);

  // User user = Metadata.unwrap('User',{'FullName':'Billy Bob'});

  // print(user.name);
}


// Javascript Examples
// User.find({ where: { name: 'foo' }, skip: 20, limit: 10, sort: 'name DESC' });
// User.find({ name: { '!' : ['Walter', 'Skyler'] }});


// [Expected] Shellstone Examples
// Model.find('User').where(['name']).eq('foo').skip(20).limit(10).sort(['name'],Desc).run();
// Model.find('User').where(['name']).ne(['Walter','Skyler']).run();
