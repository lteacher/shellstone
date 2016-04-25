# Shellstone

> A framework to use Redstone with a packaged ORM of sorts for as many DB
> types possible. Initially inspired by Sails js and modelled from that
> however it may change before becoming usable.

[![Build Status](https://api.travis-ci.org/lessonteacher/shellstone.svg?branch=master)](https://travis-ci.org/lessonteacher/shellstone)

_**Note**: This is a currently a WIP and does not actually work yet. When it is on Pub then it will be available only. If you think the idea is good you can communicate via the issues system and contribute to features_

## Usage

To be expanded on, essentially for the ORM factor I expect something like the following to be used.

```dart
import '../lib/shellstone.dart';

// Annotate this class as being a Model class with identity 'user'
@Model(identity: 'user')
class User {

  // Create the attributes. They usethe @Attr annotation
  @Attr(type: 'integer', primaryKey: true) int id;
  @Attr(type: 'string') String username;
}

```

The query language structure looks something like the following:

```dart
Model.find('User').where(['username','password']).eq(['bill','12345']).run();
```
