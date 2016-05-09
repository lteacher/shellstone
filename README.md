# Shellstone

> Inspired by Shelf, Redstone and js frameworks like Sails, Shellstone is a
> server side framework to provide a form of ORM, routing and other various
> features

[![Build Status](https://api.travis-ci.org/lessonteacher/shellstone.svg?branch=master)](https://travis-ci.org/lessonteacher/shellstone)
[![Join the chat at https://gitter.im/lessonteacher/shellstone](https://badges.gitter.im/lessonteacher/shellstone.svg)](https://gitter.im/lessonteacher/shellstone?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge)

_**Note**: This is a currently a WIP. You could technically use the current version if all your models are so simple and dont have any relations but otherwise I would suggest holding out for a later release. I have published this basic version in case anyone thinks the idea is good and wants to contribute._

## State

At this time only a very simple form of ORM is provided with a mysql adapter. The project is actively being developed and will be a lot more functional very soon. The examples provided all work but the lack of features would be quite problematic if you needed a rich schema.

#### Startup

To use any of the annotations below, Shellstone must run and scan in the metadata. Its started using the following example

```dart
import 'package:shellstone/shellstone.dart';

main() async {
  await strapIn();
}
```

#### Models

Currently you can create models by annotating a plain dart object per the following.

```dart
import 'package:shellstone/shellstone.dart';

// Annotate this class as being a Model class with identity user
@Model('user', dataSource: 'mysql')
class Person {

  // Create the attributes. They usethe @Attr annotation
  @Attr(primaryKey: true) int id;
  @Attr(unique: true) String username;
  @Attr() String password;
  @Attr(column: 'firstName') String firstname;
  @Attr(column: 'lastName') String lastname;
}
```

#### Events

You can use `Hooks` and `Listen`ers to perform functions when an event occurs. For example to set the credentials during configure you can use a hook. Hooks can intercept an event's data

```dart
import 'package:shellstone/shellstone.dart';

@Hook(Adapter.configure)
setCredentials(event) {
  var adapter = event.data;

  adapter.user = 'root';
  adapter.password = 'root';
  adapter.host = '127.0.0.1';
  adapter.db = 'test';
}
```

There are also listeners which you can do something special with

```dart
@Listen(Adapter.configure)
doSomethingSpecial(event) {
  // Who knows what, log stuff?
}
```

#### Data Access

The query language structure looks like the following simple examples:

```dart
main() async {
  // Setup Shellstone
  await Shellstone.setup();

  // Get the first user where it matches the query
  User user = await Model.find('User').where('username').eq('1234').run();

  // Get user using filter
  user = await Model.find('User').filter((user) => user.lastName == 'Smith').run();

  // Find all users
  Stream<User> users = await Model.findAll('User').run();

  /* NOTE: This section is changing in next release */
  List ids = await Model.insert(user).run();

  // Update the given user
  int modified = await Model.update(user).run();

  // Remove the user
  modified = await Model.remove(user).run();
}
```

Take a look at the tests for more examples

## Contributing

I wanted to create this project because I think dart is a really great language. Instead of `npm init`ializing another package, it seemed like a good idea to try and contribute to the Dart community instead.

I would be happy for any contributions so to try and make that as easy as possible I will be talking to myself in the issues about ideas and plans so that would also be a good place to look and know what is coming. Since the project is still far off being really usable I am breaking up ideas as features and working them into a milestone branch. Once a good base is there then will change the approach.
