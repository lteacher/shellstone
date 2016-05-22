library shellstone;

// Imports
import 'dart:async';
import 'src/internal/globals.dart';
import 'src/datalayer/adapters/mysql/mysql_adapter.dart';
import 'src/datalayer/adapters/postgres/postgres_adapter.dart';
import 'src/datalayer/database_adapter.dart';
import 'src/datalayer/schema/schema.dart';
import 'src/metadata/annotations.dart';
import 'src/metadata/metadata.dart';
import 'src/events/events.dart';
import 'src/events/adapter_events.dart';
import 'src/events/event_dispatcher.dart';
import 'src/events/event_registration.dart';

// Exports
export 'src/metadata/annotations.dart';
export 'src/metadata/metadata.dart';
export 'src/metadata/metadata_proxies.dart';
export 'src/datalayer/database_adapter.dart';
export 'src/datalayer/querylang.dart';
export 'src/datalayer/schema/schema.dart';
export 'src/datalayer/schema/schema_field.dart';
export 'src/datalayer/schema/schema_relation.dart';
export 'src/events/events.dart';
export 'src/events/event_registration.dart';
export 'src/entities/entity_wrapper.dart';
export 'src/entities/entity_builder.dart';
export 'src/models/models.dart';

/// The main [Shellstone] hook - enjoy!
///
/// This function will launch all the setups required for Shellstone to function
/// currently this means:
/// - Base adapters will be added
/// - Metadata will be scanned in from any annotations
/// - Listeners will be hooked up
/// [withAdapters] if set true will create the base adapters
/// [source] sets the default data source(which can be overridden in the @Model)
strapIn({withAdapters: true}) {
  // Load and scan for metadata
  new Metadata().scan();

  // Load schemas
  _loadSchemas();

  // Add base adapters if desired
  if (withAdapters) _addBaseAdapters();

  // Start and run the adapter methods
  return _runAdapters();
}

/// Shuts down shellstone.
///
/// All the adapters will be disconnected
shutDown() {
  return Future.forEach(_adapters.values,(adapter) => adapter.disconnect());
}

/// Retrieves an adapter by name.
///
/// For example it can retrieve supported or even added adapters such as
/// `mongo`, `mysql`, `posgres` etc
DatabaseAdapter adapters(String name) => _adapters[name];

/// Add an adapter by name
///
/// If you have a custom adapter you can physically inject it here in case
/// you hate annotations or need to do it dynamically for some insane reason
addAdapter(String name, DatabaseAdapter adapter) {
  _adapters[name] = adapter;
}

/// Adds a listener for a given [EventRegistration]
///
/// **Note** you cant listen to events that trigger during setup such as some
/// adapter events for example. To listen on those you must use the @Listen annotation
addListener(EventRegistration reg, Function f) {
  addHandler(Listen, reg, f);
}

/// Adds a hook for a given [EventRegistration]
///
/// **Note** you cant listen to events that trigger during setup such as some
/// adapter events for example. To listen on those you must use the @Listen annotation
addHook(EventRegistration reg, Function f) {
  addHandler(Hook, reg, f);
}

/// Removes a hook for a given [EventRegistration]
removeListener(EventRegistration reg, Function f) {
  removeHandler(Listen, reg, f);
}

/// Removes a hook for a given [EventRegistration]
removeHook(EventRegistration reg, Function f) {
  removeHandler(Hook, reg, f);
}

/// Allows for the triggering of some [Event] e
Future trigger(Event e) {
  return EventDispatcher.trigger(e);
}

// Used to store the adapters for function [adapters]
Map<String, DatabaseAdapter> _adapters = new Map();

// Runs all the adapter setups
Future _runAdapters() {
  // If there are no adapters just return an empty future
  if (_adapters.isEmpty) return new Future.value();

  StreamController ctrl = new StreamController.broadcast();

  var results = [];
  _adapters.forEach((key, adapter) {
    results.add(ctrl.stream
        .asyncMap((event) => EventDispatcher
            .trigger(new AdapterEvent(event, adapter))
            .then((v) => event))
        .asyncMap((event) => invokeMethod(adapter, event))
        .drain());
  });

  // Add the events to the pipe
  ctrl.add('configure');
  ctrl.add('connect');
  ctrl.add('build');
  ctrl.close();

  // Return
  return Future.wait(results);
}

/// Adds in all the base adapters
_addBaseAdapters() {
  var schemas = Schema.getAll();

  // For each schema
  schemas.forEach((schema) {
    var src = schema.source;
    // If the adapter isnt set already for this source
    if (adapters(src) == null) {
      // Setup the base adapters
      if (src == 'mysql') addAdapter(src, new MysqlAdapter());
      if (src == 'postgres') addAdapter(src, new PostgresAdapter());
    }
  });
}

// Loads schemas from all the model proxies. This used to occur in the scanner
// but moved it so that fields can be loaded which will be nicer to happen up front
_loadSchemas() {
  var meta = Metadata.modelMetadata;

  // Construct the schema which will slam it into the cache
  meta.forEach((name, proxy) => new Schema.fromMetadata(name, proxy));

  // Copies relation keys into their schemas, at least it only happens once
  // otherwise a nicer solution might be better for this...
  Schema.getAll().forEach((schema) => schema.transferDerivedFields());
}
