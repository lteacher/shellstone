import 'dart:mirrors';
import 'entity_builder.dart';
import 'entity_definition.dart';
import '../metadata/annotations.dart';
import '../metadata/metadata.dart';
import '../datalayer/schema/schema.dart';
import '../datalayer/schema/schema_field.dart';

/// Wraps an entity up to match its metadata [Model] and [Attr] descriptors
///
/// The class can also be accessed by using the [Metadata.wrap] and [Metada.unwrap]
/// methods just for convenience sake.
class EntityWrapper {
  String _name;
  dynamic _entity;
  EntityDefinition _def;
  Schema _schema;
  InstanceMirror _reflectee;

  /// A String name or an entity is provided to this constructor
  EntityWrapper(dynamic entity) {
    if (entity is String) {
      _name = entity;
      _def = EntityBuilder.getDefinition(_name);
      _entity = EntityBuilder.create(_name);
    } else {
      _entity = entity;
      _def = EntityBuilder.getDefinition(entity.runtimeType.toString());
      _name = _def.name;
    }

    _reflectee = reflect(_entity);
    _schema = Schema.get(_name);
  }

  /// Wraps an [entity] into its mapped [Model] view, e.g. converts it to its annotated
  /// form as a map of key values.
  Map<String, dynamic> wrap() {
    var result = {};
    var attributes = _schema.fields;

    // For each field
    fields.where(attributes.containsKey).forEach((field) {
      // Set the property name
      var attr = attributes[field];
      var property = attr.column ?? field;
      var value = _reflectee.getField(new Symbol(field)).reflectee;

      result[property] = _coerceType(attr.type, value);
    });

    return result;
  }

  /// Unwraps an [entity] from its mapped [Model] form.
  dynamic unwrap(Map<String, dynamic> map) {
    map.forEach((f, value) {
      // Get the field and attribute we need
      var field = _schema.getColumn(f);

      if (field != null) {
        var attr = field.name;
        var type = _def.fieldType(attr).toString();
        _reflectee.setField(new Symbol(attr), _coerceType(type, value));
      }
    });

    return _entity;
  }

  // Convert some type
  _coerceType(type, value) {
    if (value == null) return value;

    switch (type) {
      case 'string':
      case 'String':
        return value is String ? value : value.toString();
      case 'integer':
      case 'int':
        return value is int ? value : int.parse(value);
      case 'double':
        return value is double ? value : double.parse(value);
      case 'datetime':
      case 'DateTime':
        return value is DateTime ? value : DateTime.parse(value);
      default:
        return value;
    }
  }

  get fields => _def.fieldNames;
}
