library shellstone;

// Imports
import 'src/metadata/metadata.dart';
import 'src/datalayer/database_adapter.dart';

// Exports
export 'src/metadata/annotations.dart';
export 'src/metadata/metadata.dart';
export 'src/metadata/metadata_proxies.dart';
export 'src/datalayer/querylang.dart';
export 'src/datalayer/database_adapter.dart';
export 'src/util/entity_builder.dart';
export 'src/util/entity_wrapper.dart';

/// The main [Shellstone] hook - enjoy!
///
/// This function will launch all the setups required for Shellstone to function
/// currently this means:
/// - Base adapters will be added
/// - Metadata will be scanned in from any annotations
/// - Listeners will be hooked up
strapIn() {
  // Add base adapters

  // Startup the metadata
  new Metadata().scan();

  // Add listeners

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
/// **Note** setting the same name as an existing will replace that existing
addAdapter(String name, DatabaseAdapter adapter) {
  _adapters[name] = adapter;
}


/// _Coming soon - Adds a function to listen for shellstone events_
///
/// **Note** you cant listen to events that trigger during setup such as some
/// adapter events for example. To listen on those you must use the annotation
listen(event, Function function) { }

// Used to store the adapters for function [adapters]
Map<String,DatabaseAdapter> _adapters = new Map();
