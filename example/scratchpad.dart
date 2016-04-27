import '../lib/shellstone.dart';
import 'package:sqljocky/sqljocky.dart';
import 'dart:async';

@Model('User')
class User {
  @Attr(type: 'string', column: 'fullName') String name;
}

@DBAdapter('mongo')
class MongoAdapter {
  @configure setCredentials() {}
  @connect createPool(String adapter) {}
  @build createTables(adapter) {}
  @query notifySomething(adapter) {}
  @disconnect @error cleanup(adapter) {}
}

main() async {
  Shellstone.setup();

}

// Javascript Examples
// User.find({ where: { name: 'foo' }, skip: 20, limit: 10, sort: 'name DESC' });
// User.find({ name: { '!' : ['Walter', 'Skyler'] }});

// [Expected] Shellstone Examples
// Model.find('User').where(['name']).eq('foo').skip(20).limit(10).sort(['name'],Desc).run();
// Model.find('User').where(['name']).ne(['Walter','Skyler']).run();
