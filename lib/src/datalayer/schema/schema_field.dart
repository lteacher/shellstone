import 'schema.dart';
import '../../metadata/annotations.dart';
import '../../entities/entity_builder.dart';
import '../../entities/entity_definition.dart';

/// Represents a field in the schema,
///
/// The [SchemaField] sets up default values etc for different
/// types if they havent been annotated by checking with the [EntityDefinition]
/// and finding out what the inferred type shall be.
class SchemaField {
  Schema _schema;
  String name;
  Attr _attr;
  EntityDefinition _def;
  bool derived; // Indicates the field is derived from a relation

  SchemaField(this._schema, this.name, Attr this._attr,
      [this.derived = false]) {
    _def = EntityBuilder.getDefinition(_schema.name);
  }

  // Field copy, Apparently dartfmt makes this pretty ugly
  factory SchemaField.copy(SchemaField field,
      {schema, name, Attr attr, derived}) {
    return new SchemaField(schema ?? field._schema, name ?? field.name,
        attr ?? field._attr, derived ?? field.derived);
  }

  // Getters
  get type => _attr.type ?? _convertType(_def.fieldType(name));
  get index => _attr.index;
  get column => _column;
  get primaryKey => _attr.primaryKey;
  get length => _attr.length ?? 0;
  get unique => _attr.unique;

  // If the field is a primary key and the auto isnt set then it defaults to true
  get autoIncr => _attr.autoIncr == null ? primaryKey : false;

  // Map column, postgres is case insensitive... hmmm
  String get _column => _schema.source == 'postgres'
      ? (_attr.column ?? name).toLowerCase()
      : _attr.column ?? name;

  // Converts a type to a 'schema' type
  String _convertType(Type t) {
    switch (t) {
      case String:
        return 'string';
      case int:
        return 'integer';
      case double:
        return 'double';
      case DateTime:
        return 'datetime';
      case bool:
        return 'boolean';
      default:
        throw 'Unsupported type `$t` for annotated Attr() `$name`';
    }
  }
}
