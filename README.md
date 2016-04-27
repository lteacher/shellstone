# Shellstone

[![Join the chat at https://gitter.im/lessonteacher/shellstone](https://badges.gitter.im/lessonteacher/shellstone.svg)](https://gitter.im/lessonteacher/shellstone?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge)

> Inspired by Shelf, Redstone and js frameworks like Sails. Shellstone is a
> framework to simplify server development via auto routing, ORM and other
> features.

[![Build Status](https://api.travis-ci.org/lessonteacher/shellstone.svg?branch=master)](https://travis-ci.org/lessonteacher/shellstone)

_**Note**: This is a currently a WIP. There is a milestone to track the first usable
release so if you want to contribute I will be trying very hard to make that easy. In the development phase I will leave the below heading and description until clearer, finalised documentation can be provided in its stead_

## Preface

Dart is a really great language. However, it lacks the sheer quantity
of community packages and support that Javascript has with NodeJS + NPM etc.

Instead of `npm init`ializing another package, it seemed like a good idea to try and contribute to the Dart community instead in the hopes that more people will use such a nice language.

## Planned Usage

The following section indicates the usage concepts that are imagined so far. These are potentially changing so they are definitely not final but at least they provide a relatively nice guide.

#### Modelling

```dart
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
  @Rel('1:n') List<Role> roles;
}
```

#### Enhanced Modelling

```dart
@Model('person')
class Person extends BaseModel with Transactional {
  //<== CONCEPTS
  // @Attr(column: '_id') int id;   Provided by BaseModel
  // @Attr() DateTime createdAt;    ^^
  // @Attr() DateTime updatedAt;    ^^

  // save();          Provided by Transactional
  // rollback();      ^^

  @Attr(type: 'string') String firstName;
  @Attr(type: 'string') String lastName;
}

```

#### Data Access

The query language structure should look something like the following:

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
}
```

## Contributing

I would be happy for any contributions so to try and make that as easy as possible most features will be listed in the issues. Milestones will describe an aim, the issue will describe the feature and allow for discussion. Obviously branches will link to the feature. Features will probably be merged to the Milestone. I may end up just typing to myself... but just in case, it should be very clear :)
