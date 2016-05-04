import 'package:quiver/core.dart';

/// Defines a registration to a certain type of event
///
/// [Event]s are based on certain other types within shellstone. for example
/// the [Adapter] has a number of registrations as as they indicate what events
/// will be produced. You can use an [EventRegistration] as the input to a
/// [Hook] or a [Listen] annotation
class EventRegistration {
  final Type type;
  final String name;

  const EventRegistration(this.type, this.name);

  bool operator ==(o) => o is EventRegistration && name == o.name && type == o.type;
  int get hashCode => hash2(name.hashCode, type.hashCode);
}
