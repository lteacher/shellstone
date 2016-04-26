import '../lib/shellstone.dart';

// Models can be defined with annotations
@Model('user')
class User {
  // Attributes are specified in the same way
  @Attr(type: 'integer', primaryKey: true) int id;
  @Attr(type: 'string') int username;
  @Attr(type: 'string') int password;
  @Attr(type: 'boolean') bool archived;

  // Relations to come (this annotation is conceptual)
  // @Rel('1:n') List<Role> roles;
}

// @Model('person')
// class Person extends BaseModel with Transactional {
//   //<== CONCEPTS
//   // @Attr(column: '_id') int id;   Provided by BaseModel
//   // @Attr() DateTime createdAt;    ^^
//   // @Attr() DateTime updatedAt;    ^^
//
//   // save();          Provided by Transactional
//   // rollback();      ^^
//
//   @Attr(type: 'string') String firstName;
//   @Attr(type: 'string') String lastName;
// }

// main() async {
//   // Setup Shellstone
//   await Shellstone.setup();
//
//   // Get the first user where it matches the query
//   User user = await Model.find('User').where('username').eq('1234').run();
//
//   // Get user using filter
//   user = await Model.find('User').filter((user) => user.lastName == 'Smith').run();
//
//   // Find all users
//   Stream<User> users = await Model.findAll('User').run();
// }
