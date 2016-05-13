import 'package:shellstone/shellstone.dart';

// Annotate this class as being a Model class with identity user
@Model(name: 'person', source: 'mysql')
class Person {

  // Create the attributes. They usethe @Attr annotation
  @Attr() int id;
  @Attr() String username;
  @Attr() String password;
  @Attr() String firstName;
  @Attr() String lastName;
}
