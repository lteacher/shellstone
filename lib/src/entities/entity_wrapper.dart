import 'dart:mirrors';
import 'entity_builder.dart';
import 'entity_definition.dart';
import '../metadata/annotations.dart';
import '../metadata/metadata.dart';
import '../datalayer/schema.dart';

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

    // For each field
    fields.where(attributes.containsKey).forEach((field) {
      Attr attr = attributes[field];

      // Set the property name
      var property = attr.field ?? field;
      var value = _reflectee.getField(new Symbol(field)).reflectee;

      // Set the value, null or not
      result[property] = _coerceType(attr.type, value);
    });

    return result;
  }

  /// Unwraps an [entity] from its mapped [Model] form.
  dynamic unwrap(Map<String, dynamic> map) {
    map.forEach((f, value) {
      // Get the attribute we need
      var field = _getAttrField(f);

      if (field != null) {
        var type = _def.fieldType(field).toString();

        _reflectee.setField(new Symbol(field), _coerceType(type, value));
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
        return value.toString();
      case 'integer':
      case 'int':
        return int.parse(value);
      default:
        return value;
    }
  }

  // Gets the annotated field on the class
  // Need to think of a way to make this more efficient!!
  String _getAttrField(field) {
    // If this field is in the attributes then it can be returned directly
    if (attributes.containsKey(field)) return field;

    // Otherwise we need to search for the field which sucks big time
    var result;
    attributes.forEach((n, attr) {
      if (attr.field == field) {
        result = n;
        return;
      }
    });

    return result;
  }

  get fields => _def.fieldNames;
  get attributes => _schema.fields;
}
