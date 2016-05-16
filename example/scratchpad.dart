import 'dart:async';
import 'package:shellstone/shellstone.dart';

@Model(migration: 'drop')
class User {
  @Attr(primaryKey:true) int id;
  @Attr() String firstName;
  @Attr() String lastName;
  @Attr() String username;
  @Attr() String password;
}

main() async {
  await strapIn();

  User user = new User()..firstName = 'Bill'
                        ..lastName = 'Smith'
                        ..username = 'smarg'
                        ..password = '2323';

  var test = new HandlerTest();
  addHook(const EventRegistration(String, 'count'),test.printCount);


  trigger(new Event(String, 'count'));
  trigger(new Event(String, 'count'));
  trigger(new Event(String, 'count'));


  await Model.insertFrom(user).run();

  // Find all users?
  var users = await Model.findAll(User).run();

}

class HandlerTest {
  int count = 0;
  printCount(event) => print(count++);
}


// Javascript Examples
// User.find({ where: { name: 'foo' }, skip: 20, limit: 10, sort: 'name DESC' });
// User.find({ name: { '!' : ['Walter', 'Skyler'] }});

// [Expected] Shellstone Examples
// Model.find('User').where(['name']).eq('foo').skip(20).limit(10).sort(['name'],Desc).run();
// Model.find('User').where(['name']).ne(['Walter','Skyler']).run();
