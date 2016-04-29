part of shellstone;

/// Defines the type that will be used to match the annotated handlers
typedef DatabaseAdapter DBEventHandler(adapter);

/// A first cut attempt at some thing that processes an adapter event
/// not so happy with it so will revise this area later
class AdapterEvent {
  String name;
  AdapterProxy proxy;
  dynamic custom;

  AdapterEvent(this.name) {
    if (Metadata.exists('adapter', name)) {
      proxy = Metadata.proxy('adapter', name);
      custom = proxy.instance.reflectee;
    }
  }

  /// processes some [event] by name e.g. 'configure' for an adapter
  /// and all of its annotated mutators
  Future process(event) {
    // Get the base adapter
    var base = _getBaseAdapter();

    // Create the stream for the output
    Stream stream = new Stream.fromIterable([base]);

    if (proxy != null) {
      // Get any handler for the event and set into map
      if (proxy.dependents.containsKey(event)) {
        // set the function
        var f = proxy.dependents[event];

        // Add the mapping but wrap it in a sort of catch in case it isnt
        // returned and also so that the global adapter is updated
        stream = stream.asyncMap((adapter) {
          var result = f(adapter);

          if (result == null) result = adapter;

          // Return and update the global
          return result;
        });
      }
    }

    // Set the listen up to invoke the relevant method
    var sub = stream.listen(
        (adapter) => smoke.invoke(adapter, new Symbol(event), new List()));

    // Return future subscription done
    return sub.asFuture();
  }

  // Get the base adapter
  DatabaseAdapter _getBaseAdapter() {
    if (custom is DatabaseAdapter) Shellstone.adapters[name] = custom;

    return Shellstone.adapters[name];
  }
}
