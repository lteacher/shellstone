import 'dart:async';
import 'events.dart';
import '../util/globals.dart';
import '../notification/event_registration.dart';

/// Dispatches events for the shellstone framework
class EventDispatcher {
  const EventDispatcher();

  /// Triggers an event by [Type], [name] with the given data.
  ///
  /// for example: `triggerEvent(Adapter,'configure',_adapter)`
  static Future triggerEvent(Type t, String name, {dynamic data, loc: 'pre'}) =>
      trigger(new Event(t, name, data, loc));

  /// Triggers an event by a given registration
  static Future triggerRegistration(EventRegistration reg,
          {dynamic data, loc: 'pre'}) =>
      trigger(new Event(reg.type, reg.name, data, loc));

  /// Triggers a given [Event] object
  static Future trigger(Event e) {
    EventRegistration reg = new EventRegistration(e.t, e.name);

    // Dispatch any listeners
    _dispatchListeners(e, reg);

    // Dispatch the hooks
    return _dispatchHooks(e, reg);
  }

  // Dispatches the event for the registered listeners via broadcast stream
  static _dispatchListeners(Event e, EventRegistration reg) {
    // No need to do anything if not registered
    if (!listeners.containsKey(reg)) return;

    StreamController ctrl = new StreamController.broadcast();
    Stream stream = ctrl.stream;

    listeners[reg].where((EventHandler h) => h.loc == e.loc).forEach((f){
      // Add each handler's delegeate as a listener
      stream.listen(f.delegate);
    });

    // Add the event and close the stream
    ctrl.add(e);
    ctrl.close();
  }

  // Dispatches the event for the hooks in order returning the future
  static Future _dispatchHooks(Event e, EventRegistration reg) {
    // No hooks return an empty future
    if (!hooks.containsKey(reg)) return new Future.value();

    // Create stream from the event
    Stream stream = new Stream.fromIterable([e]);

    hooks[reg].where((EventHandler h) => h.loc == e.loc).forEach((f){
      // Add each handler's delegeate into the stream mapping
      stream = stream.asyncMap((event) => f.delegate(event) ?? event);
    });

    // Return the stream passed through its mappings
    return stream.drain();
  }
}
