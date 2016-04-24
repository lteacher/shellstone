import '../lib/shellstone.dart';

@Model()
class User {
  @Attr(type: 'string') String name;
}

main() {
  Shellstone.start();
}


// Waterline Examples
// User.find({ where: { name: 'foo' }, skip: 20, limit: 10, sort: 'name DESC' });
// User.find({ name: { '!' : ['Walter', 'Skyler'] }});


// [Expected] Shellstone Examples
// Model.find('User').where(['name']).eq('foo').skip(20).limit(10).sort(['name'],Desc).run();
// Model.find('User').where(['name']).ne(['Walter','Skyler']).run();
