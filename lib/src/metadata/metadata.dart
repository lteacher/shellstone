import 'dart:mirrors';
import 'annotations.dart';
import 'metadata_proxies.dart';
import 'metadata_scanner.dart';
import '../util/entity_wrapper.dart';

/// Encapsulates the utility functions of looking up model annotated data
///
/// The [Metadata] class scans the libraries on startup using mirrors to find
/// the Shellstone relevant annotations and their reflectees. These are captured
/// so that they can be looked up later for various uses throughout the framework
/// most methods are static but leverage the underlying singleton. This means
/// the ugly new keyword style can be hidden from the consumers
class Metadata {
  // Metadata singleton
  static final Metadata _meta = new Metadata._internal();
  factory Metadata() => _meta;
  Metadata._internal();
  MetadataScanner _scanner;

  /// Gets a [MetadataProxy] by [Type] and [name]
  static MetadataProxy get(Type type, String name) =>
      type == Model ? _modelProxy(name) : _adapterProxy(name);

  /// Lookup a [Model] object by [name]
  static Model model(String name) => _modelProxy(name).model;

  /// Returns the attributes Map for the model [name]
  static Map<String, Attr> attr(String name) => _modelProxy(name).dependents;

  /// Returns the name for the entity or list of entities
  static String name(dynamic entity) {
    if (entity is List) entity = entity[0];

    ClassMirror m = reflect(entity).type;
    var name = MirrorSystem.getName(m.simpleName);
    var proxy = _modelProxy(name); // Trigger a exception if non-existent

    return name;
  }

  /// Returns the [Adapter] metadata by [name]
  static Adapter adapter(String name) => _adapterProxy(name).adapter;

  // /// Returns the [DBAdapter] @event handlers for a given adapter [name]
  // static Map<String, dynamic> handlers(String name) =>
  //     _adapterProxy(name).dependents;

  /// Tests the existence of some kind of metadata
  static bool exists(String type, String name) {
    return type == 'model'
        ? _meta._scanner.models.containsKey(name)
        : _meta._scanner.adapters.containsKey(name);
  }

  /// Wraps an [entity] into its mapped [Model] view, e.g. converts it to its annotated
  /// form as a map of key values.
  static Map<String, dynamic> wrap(dynamic entity) =>
      new EntityWrapper(entity: entity).wrap();

  /// Unwraps an entity from its mapped [Model] form.
  static dynamic unwrap(String name, Map<String, dynamic> map) =>
      new EntityWrapper(name: name).unwrap(map);

  /// Scans for relevant metadata. This needs to be called to setup the object
  /// as otherwise lazy initialisation would occur and not be desirable
  scan() {
    _scanner = new MetadataScanner.scan();
  }

  // Utility to retrieve a Model proxy out
  static _modelProxy(name) {
    var proxy = _meta._scanner.models[name];

    return proxy != null ? proxy : throw 'Unknown model type $name';
  }

  // Utility to retrieve an Adapter proxy out
  static _adapterProxy(name) {
    var proxy = _meta._scanner.adapters[name];

    return proxy != null ? proxy : throw 'Unknown adapter $name';
  }
}
