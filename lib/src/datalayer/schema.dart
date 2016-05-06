// import '../metadata/annotations.dart';
// import '../metadata/metadata.dart';
import '../metadata/metadata_proxies.dart';
import '../internal/globals.dart';

/// Acts as an interpretation of a form of `schema` in shellstone terms
///
/// The schema is of course not a correct database schema, its purpose
/// is to provide the data relevant attributes based off some annotated model
class Schema {
  static Map<String,Schema> _schemas = {};
  String name;
  ModelMetadata _meta;

  Schema._(this.name,[this._meta]);

  /// Gets a schema by [name]
  static Schema get(name) {
    if (!_schemas.containsKey(name)) throw 'No schema exists for $name';

    return _schemas[name];
  }

  // Gets all the known schemas
  static List<Schema> getAll() => _schemas.values;

  /// Creates a new schema or retrieves from the cache
  factory Schema.fromMetadata(name,ModelMetadata meta){
    // Schema is in the cache so return it
    if (_schemas.containsKey(name)) return _schemas[name];

    // Else create and return new
    return _schemas.putIfAbsent(name, () => new Schema._(name,meta));
  }

  String get resource => _meta.model.resource;
  String get source => _meta.model.source ?? defaultSource;
  String get migration => _meta.model.migration;
  Map<String,dynamic> get fields => _meta.dependents;
  dynamic getField(String name) => fields[name];
}
