import 'event_registration.dart';

/// Type definition for something that wants to [Listen] or [Hook] in to.
typedef dynamic HandlerFunction(Event e);

/// Defines a handler for an [EventRegistration]
///
/// An [EventHandler] is constructed by the [Hook] and [Listen] annotations
/// to indicate when and what will occur when the registered [Event] is triggered
class EventHandler {
  final EventRegistration reg;
  final Function delegate; // Maybe it should be possible to use class methods?

  const EventHandler(this.reg, this.delegate);
}

/// Defines an event class
class Event {
  Type t;
  String name;
  dynamic data;

  Event(this.t,this.name,[this.data]);
}
