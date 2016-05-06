import 'package:shellstone/shellstone.dart';

// Used to contain any setup specific files, for example Model definitions
@Model('user')
class User {
  @Attr(type: 'integer', primaryKey: true) int id;
  @Attr(type: 'string') String username;
  @Attr(type: 'string') String password;
  @Attr(type: 'string') String firstName;
  @Attr(type: 'string') String lastName;
}

@Model('person', source: 'mongo')
class Person {
  @Attr(type: 'integer', primaryKey: true) int id;
  @Attr(type: 'string', field: 'FirstName') String firstName;
  @Attr(type: 'string', field: 'LastName') String lastName;
  @Attr(type: 'integer', field: 'Age') String age;
}

@Adapter('mongo')
class CustomMongoAdapter extends DatabaseAdapter {

  get name => 'mongo';
  get driver { }

  configure() {}
  connect() {}
  build() {}
  disconnect() {}
  execute(chain) {}
}
