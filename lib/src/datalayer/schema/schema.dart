import 'schema_field.dart';
import 'schema_relation.dart';
import '../../metadata/metadata_proxies.dart';
import '../../metadata/annotations.dart';
import '../../internal/globals.dart';

/// Acts as an interpretation of a form of `schema` in shellstone terms
///
/// The schema exists to provide an abstract representation of the field types
/// which were annotated outside of shellstone. It is as flat as possible even
/// with duplicate references in some cases in order to make lookups as fast as
/// possible.
class Schema {
  // Cache of all schemas
  static Map<String, Schema> _schemas = {};
  Map<String, SchemaField> _fields = {}; // All fields
  Map<String, SchemaField> _indexes = {}; // Fields that are index: true
  Map<String, SchemaField> _columns = {}; // Fields by their column name
  Map<String, SchemaField> _derived = {}; // Fields that ref another Schema
  Map<String, SchemaRelation> _relations = {};
  ModelMetadata _meta;

  String name;
  SchemaField primaryKey;

  Schema._(this.name, [this._meta]) {
    // Build the schema fields and relations
    _buildFields();
    _buildRels();
  }

  /// Gets a schema by [name]
  static Schema get(name) {
    if (!_schemas.containsKey(name)) throw 'No schema exists for $name';

    return _schemas[name];
  }

  // Gets all the known schemas
  static Iterable<Schema> getAll() => _schemas.values;

  /// Creates a new schema or retrieves from the cache
  factory Schema.fromMetadata(name, ModelMetadata meta) {
    // Schema is in the cache so return it
    if (_schemas.containsKey(name)) return _schemas[name];

    // Else create and return new
    return _schemas.putIfAbsent(name, () => new Schema._(name, meta));
  }

  // Loads up the fields for the schema into the various flattened collections
  _buildFields() {
    _meta.attributes.forEach((name, attr) {
      var field = new SchemaField(this, name, attr);

      // Add to fields and columns
      _fields[name] = field;
      _columns[field.column] = field;

      // if its a primary key add it here
      if (field.primaryKey) primaryKey = field;
      if (field.index) _indexes[name] = field;
    });
  }

  // Builds the relations / associations between models
  _buildRels() {
    _meta.relations.forEach((name, rel) {
      var relation = new SchemaRelation(this, name, rel);

      // Add to relations
      _relations[name] = relation;
    });
  }

  // Updates schemas with new derived fields from their relations
  transferDerivedFields() {
    _relations.forEach((name, rel) {
      // Get the schema which this relation is pointing to
      var schema = Schema.get(rel.model.toString());

      // Get relevant schema field from this schema
      var name = rel.as;
      var field = getField(rel.by);
      var derived = new SchemaField.copy(field,
          name: name,
          attr: new Attr(
              type: field.type,
              column: name,
              index: true,
              length: field.length),
          derived: true);

      // Add to derived fields and indexes
      schema._derived[name] = derived;
      schema._indexes[name] = derived;
    });
  }

  /// Gets the resource name, which is usually a table or collection
  String get resource => _meta.model.name;

  /// Gets the source, which would be a database type e.g. `mysql`
  String get source => _meta.model.source ?? defaultSource;

  /// Gets the migration strategy, which is used to determine how to build tables
  String get migration => _meta.model.migration;

  /// Retrieves all fields as written per the object
  Map<String, SchemaField> get fields => _fields;

  /// Returns all fields including derived, useful for table creation
  Map<String, SchemaField> get allFields {
    var all = new Map.from(_fields);
    all.addAll(_derived);
    return all;
  }

  /// Retrieves all indexes as written per the object
  Map<String, SchemaField> get indexes => _indexes;

  /// Retrieves all fields which are attached through relations
  Map<String, SchemaField> get derived => _derived;

  /// Retrieves a single field by name
  SchemaField getField(String name) => fields[name];

  /// Retrieves a single field by its column, which _may_ be the same as the name
  SchemaField getColumn(String name) => _columns[name];

  /// Retreives a single derived field by name (which is the column name)
  SchemaField getDerived(String name) => _derived[name];

  /// Retrieves a schema relation by its name
  SchemaRelation getRelation(String name) => _relations[name];
}
