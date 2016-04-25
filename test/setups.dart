import '../lib/shellstone.dart';

// Used to contain any setup specific files, for example Model definitions
@Model(identity: 'user', connection: 'mongodb', autoCreatedAt: true, autoUpdatedAt: true)
class User {
  @Attr(type: 'integer', primaryKey: true) int id;
  @Attr(type: 'string', column: 'user_name') String username;
  @Attr(type: 'string') String password;
}

@Model(identity: 'person')
class Person {
  @Attr(type: 'integer', primaryKey: true) int id;
  @Attr(type: 'string', column: 'FirstName') String firstName;
  @Attr(type: 'string', column: 'LastName') String lastName;
  @Attr(type: 'integer', column: 'Age') String age;
}
