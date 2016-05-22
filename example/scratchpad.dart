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

}
