# Shellstone

> A framework to use Redstone with a packaged ORM of sorts for as many DB
> types possible. Initially inspired by Sails js and modelled from that
> however it may change before becoming usable.

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
