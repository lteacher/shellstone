import 'dart:mirrors';
import '../metadata/annotations.dart';
import '../events/events.dart';
import '../events/event_registration.dart';

/// Contains some stuff that is nice at the `shellstone.dart` level but
/// I dont want to expose to anyone outside of the library

// Used to store the global listeners
Map<EventRegistration, List<EventHandler>> listeners = new Map();

// Used to store the global hooks
Map<EventRegistration, List<EventHandler>> hooks = new Map();

// Call a method
dynamic invokeMethod(object, name) {
  return reflect(object).invoke(new Symbol(name), new List()).reflectee;
}

// Add a handler which is a listener or a hook
addHandler(Type t,reg,f) {
  List handlers;

  if (t == Listen) {
    handlers = listeners.putIfAbsent(reg, () => new List());
  } else {
    handlers = hooks.putIfAbsent(reg, () => new List());
  }

  // Try to find an entry with the given function
  handlers.firstWhere((EventHandler h) => h.delegate == f, orElse: () {
    // Else add it in
    handlers.add(new EventHandler(reg, f));
  });
}

// Remove a handler
removeHandler(Type t,reg,f) {
  if (t == Listen) {
    if (!listeners.containsKey(reg)) return;

    listeners[reg].removeWhere((EventHandler h) => h.delegate == f);
  } else {
    if (!hooks.containsKey(reg)) return;

    hooks[reg].removeWhere((EventHandler h) => h.delegate == f);
  }
}

final String defaultSource = 'mysql';
