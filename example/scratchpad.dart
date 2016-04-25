import '../lib/shellstone.dart';

@Model()
class User {
  @Attr(type: 'string', column: 'FullName') String name;
  @Attr() int count;

  doStuff() {

  }
}

main() {
  Shellstone.start();

  // Model.find('User').where(['username','password']).eq(['bill','12345']).run();

  // User user = EntityBuilder.create('User',{const Symbol('name'):'Jimmah'});
  //
  // Map wrapped = Metadata.wrap(user);

  User user = Metadata.unwrap('User',{'FullName':'Billy Bob'});

  print(user.name);
}


// Waterline Examples
// User.find({ where: { name: 'foo' }, skip: 20, limit: 10, sort: 'name DESC' });
// User.find({ name: { '!' : ['Walter', 'Skyler'] }});


// [Expected] Shellstone Examples
// Model.find('User').where(['name']).eq('foo').skip(20).limit(10).sort(['name'],Desc).run();
// Model.find('User').where(['name']).ne(['Walter','Skyler']).run();
