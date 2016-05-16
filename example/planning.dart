import '../lib/shellstone.dart';

@Model() // 'name' is auto set to Classname in lowercase e.g 'user'
class User {
  // Attribute definitions
  @Attr(primaryKey: true) int id;
  @Attr() String username;
  @Attr() String password;

  // Has one to many 'roles', the model relation is inferred by <Role>
  @Rel() List<Role> roles;
}

@Model()
class Role {
  // Belongs to user, using model type for example if type cant be inferred
  @Rel(model: User) dynamic user;
}

main() async {
  // Setup Shellstone
  await strapIn();

  // Get the first user where it matches the query
  User user = await Model.find('User').where('username').eq('1234').incl('roles').run();

}
