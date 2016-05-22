import '../lib/shellstone.dart';

@Model(migration: 'drop') // 'name' is auto set to Classname in lowercase e.g 'user'
class User {
  // Attribute definitions
  @Attr(primaryKey: true) int id;
  @Attr() String username;
  @Attr() String password;

  // Has one to many 'roles', the model relation is inferred by <Role>
  @Rel(by: 'id', as: 'user_id') List<Role> roles;
}

@Model(migration: 'drop')
class Role {
  @Attr(primaryKey: true) int id;

  // Belongs to user, using model type for example if type cant be inferred
  @Rel() User user;
}

main() async {
  // Setup Shellstone
  await strapIn();

  // // Get the first user where it matches the query
  // User user = await Model.find('User').where('username').eq('1234').incl('roles').run();
}
