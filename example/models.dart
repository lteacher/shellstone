import 'package:shellstone/shellstone.dart';

// Annotate this class as being a Model class with identity user
@Model('user', source: 'mysql')
class Person {

  // Create the attributes. They usethe @Attr annotation
  @Attr(type: 'integer') int id;
  @Attr(type: 'string') String username;
  @Attr(type: 'string') String password;
  @Attr(type: 'string') String firstName;
  @Attr(type: 'string') String lastName;
}
