import '../lib/shellstone.dart';
// import 'package:sqljocky/sqljocky.dart';
// import 'dart:async';

@Model('User')
class User {
  @Attr(type: 'string', column: 'fullName') String name;
  @Attr(type: 'string', column: 'faceThingo') String faceThingo;
}

main() async {
  strapIn();

  var result = Metadata.wrap(new User()..name = 'Bill');
  var user = Metadata.unwrap('User', result);
}

// Javascript Examples
// User.find({ where: { name: 'foo' }, skip: 20, limit: 10, sort: 'name DESC' });
// User.find({ name: { '!' : ['Walter', 'Skyler'] }});

// [Expected] Shellstone Examples
// Model.find('User').where(['name']).eq('foo').skip(20).limit(10).sort(['name'],Desc).run();
// Model.find('User').where(['name']).ne(['Walter','Skyler']).run();
