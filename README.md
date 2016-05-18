# Shellstone

> Inspired by Shelf, Redstone and js frameworks like Sails, Shellstone is a
> server side framework to provide a form of ORM, routing and other various
> features

[![Build Status](https://api.travis-ci.org/lteacher/shellstone.svg?branch=master)](https://travis-ci.org/lteacher/shellstone)
[![Join the chat at https://gitter.im/lessonteacher/shellstone](https://badges.gitter.im/lessonteacher/shellstone.svg)](https://gitter.im/lessonteacher/shellstone?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge)

_**Note**: This is a currently a WIP. It is still a pre-release and its not possible to do relations currently_

## State

Currently it is possible to connect to a DB and access data via the model definitions and the query syntax. The next features to arrive will be the table creation and relations between models which will put the project to at least a usable version. In the current form there is an adapter for `mysql` and `postgres`.

#### Startup

Shellstone is driven by annotated definitions. Primarily the `@Model` and `@Attr` annotations which define a `Model` which translates to essentially a table or collection and the `Attr` which defines fields or columns.

To be able to use the annotations, Shellstone must run and scan in the metadata. It is started using the following example:

```dart
import 'package:shellstone/shellstone.dart';

main() async {
  await strapIn();
}
```

#### Models

You can annotate a `@Model` as per the following simple example

```dart
import 'package:shellstone/shellstone.dart';

// Annotate this class as being a Model class which corresponds table 'user'
@Model(name: 'user', source: 'mysql')
class User {

  // Create the attributes. They usethe @Attr annotation
  @Attr(primaryKey: true) int id;
  @Attr(unique: true) String username;
  @Attr() String password;
  @Attr(column: 'firstName') String firstname;
  @Attr(column: 'lastName') String lastname;
}
```

The following attributes are possible for the `@Model` annotation

- `name` - _The name of the underlying table. Defaults to the name of the annotated class_
- `source` - _The source database, e.g. `postgres`. Defaults to `mysql`_
- `migration` - _The migration strategy to use for table / db construction during `build`. Defaults to `safe`_

#### Attributes

Defined with the `@Attr` annotation shown above, currently a field must be annotated for it to be included in a model. A later feature will change this. The possible values are

- `primaryKey` - _Indicates that the field is the primary key. Currently this is **required** for at least one field_
- `type` - _The type of the field in the database. By default this is inferred from the dart type declared. Current possible types are: `string`,`integer`,`double`,`datetime`* _(Coming soon...)_
- `column` - _The name of the field. By default the declaration is used but this can be use to override. The Postgres adapter, for example, sneakily changes these to lower case_

There are more fields but they are not yet implemented so they will be added to the doc once complete.

#### Events

You can use `Hooks` and `Listen`ers to perform functions when an event occurs. A common case will be to setup the database connection parameters during the configure event. Note that the event would be triggered for each adapter in the below example and the `event.data` would have a `name == <adapter>` there.

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

_A lot more events will be coming. With that, there may be changes to this so take that into consideration._

#### Data Access

There is a form of query chain that can be build up to interact with data. The query language structure looks like the following simple examples:

```dart
main() async {
  // Setup Shellstone
  await Shellstone.setup();

  // Get the first user where it matches the query
  User user = await Model.find(User).where('username').eq('1234').run();

  // Get user using filter (the filter is lazily executed on the streaming query results)
  user = await Model.find('User').filter((user) => user.lastName == 'Smith').run();

  // Find all users (String or Type are valid args)
  List<User> users = await Model.findAll('User').run();

  // Insert a user object
  List ids = await Model.insertFrom(user).run();

  // Insert some values to the user set
  List ids = await Model.insert(User,{
    'firstName': 'Bill',
    'lastName': 'Smith'
  }).run();

  // Update the given user
  int modified = await Model.updateFrom(user).run();

  // Remove the user
  modified = await Model.removeFrom(user).run();

  // Update a user by condition
  modified = await Model.update(User,{
    'lastName':'Jones'
  }).where('lastName').eq('Smith').run();
}
```

The following actions are available:

- `find` - _Find the first entity matching some condition or filter_
- `findAll` - _Find all the entities matching some condition or filter_
- `insert` - _Insert some values into a defined model as a map of name / values or a list of maps_
- `insertFrom` - _Insert from some constructed entity or list of entities_
- `update` - _Update some values into a defined model as a map of name / values_
- `updateFrom` - _Update some entities by their constructed instances_
- `remove` - _Remove entities where they match some query chain_
- `removeFrom` - _Remove entities by referencing a constructed instance or list of instances_

_In cases where entities are provided, the `primaryKey` is used as the lookup and so that is why it is required._

Take a look at the tests for even more examples

## Roadmap

Check the issues for a clearer set of upcoming features. However know that the following are features that are in the immediate future

- Relations between models
- Richer query set including modifiers

## Contributing

I wanted to create this project because I think dart is a really great language. Instead of `npm init`ializing another package, it seemed like a good idea to try and contribute to the Dart community instead.

I would be happy for any contributions so to try and make that as easy as possible I will be talking to myself in the issues about ideas and plans so that would also be a good place to look and know what is coming. Since the project is still far off being really usable I am breaking up ideas as features and working them into a milestone branch. Once a good base is there then will change the approach.
