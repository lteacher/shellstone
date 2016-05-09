import 'schema_field.dart';
import '../../metadata/metadata_proxies.dart';
import '../../internal/globals.dart';

/// Acts as an interpretation of a form of `schema` in shellstone terms
///
/// The schema exists to provide an abstract representation of the field types
/// which were annotated outside of shellstone. It is as flat as possible even
/// with duplicate references in some cases in order to make lookups as fast as
/// possible.
class Schema {
  // Cache of all schemas
  static Map<String,Schema> _schemas = {};
  Map<String,SchemaField> _fields = {};  // All fields
  Map<String,SchemaField> _indexes = {}; // Fields that are index: true
  Map<String,SchemaField> _columns = {}; // Fields by their column name
  ModelMetadata _meta;

  String name;
  SchemaField primaryKey;

  Schema._(this.name,[this._meta]) {
    // Build the schema fields out
    _buildFields();
  }

  /// Gets a schema by [name]
  static Schema get(name) {
    if (!_schemas.containsKey(name)) throw 'No schema exists for $name';

    return _schemas[name];
  }

  // Gets all the known schemas
  static Iterable<Schema> getAll() => _schemas.values;

  /// Creates a new schema or retrieves from the cache
  factory Schema.fromMetadata(name,ModelMetadata meta){
    // Schema is in the cache so return it
    if (_schemas.containsKey(name)) return _schemas[name];

    // Else create and return new
    return _schemas.putIfAbsent(name, () => new Schema._(name,meta));
  }

  // Loads up the fields for the schema into the various flattened collections
  _buildFields() {
    _meta.dependents.forEach((name,attr) {
      var field = new SchemaField(this, name, attr);

      // Add to fields and columns
      _fields[name] = field;
      _columns[field.column] = field;

      // if its a primary key add it here
      if (field.primaryKey) primaryKey = field;
      if (field.index) _indexes[name] = field;
    });
  }

  /// Gets the resource name, which is usually a table or collection
  String get resource => _meta.model.resource;

  /// Gets the source, which would be a database type e.g. `mysql`
  String get source => _meta.model.source ?? defaultSource;

  /// Gets the migration strategy, which is used to determine how to build tables
  String get migration => _meta.model.migration;

  /// Retrieves all fields as written per the object
  Map<String,SchemaField> get fields => _fields;

  /// Retrieves all indexes as written per the object
  Map<String,SchemaField> get indexes => _indexes;

  /// Retrieves a single field by name
  SchemaField getField(String name) => fields[name];

  /// Retrieves a single field by its column, which _may_ be the same as the name
  SchemaField getColumn(String name) => _columns[name];
}
