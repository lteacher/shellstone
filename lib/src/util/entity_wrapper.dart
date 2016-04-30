import 'dart:mirrors';
import '../metadata/annotations.dart';
import '../metadata/metadata.dart';
import 'entity_builder.dart';

/// Wraps an entity up to match its metadata [Model] and [Attr] descriptors
///
/// The class can also be accessed by using the [Metadata.wrap] and [Metada.unwrap]
/// methods just for convenience sake.
class EntityWrapper {
  static Map<Type, List<String>> _fieldCache = new Map();

  dynamic entity;
  String name;
  Map attributes;
  InstanceMirror _reflectee;

  /// At least [entity] or [name] must be provided on construction
  EntityWrapper({this.entity, this.name}) {
    if (entity == null && name == null)
      throw 'At least one arg must be provided to the EntityWrapper';

    if (entity == null) entity = EntityBuilder.create(name);
    if (name == null) name = Metadata.name(entity);
    attributes = Metadata.attr(name);
    _reflectee = reflect(entity);
  }

  /// Wraps an [entity] into its mapped [Model] view, e.g. converts it to its annotated
  /// form as a map of key values.
  Map<String, dynamic> wrap() {
    var result = {};

    // For each field
    fields.where(attributes.containsKey).forEach((field) {
      Attr attr = attributes[field];

      // Set the property name
      var property = attr.column != null ? attr.column : field;
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
        var type = _getType(field);

        _reflectee.setField(new Symbol(field), _coerceType(type, value));
      }
    });

    return entity;
  }

  // Convert some type, this is primitive. TODO: Do something better here
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

    // Otherwise we need to search for the column which sucks big time
    var result;
    attributes.forEach((n, attr) {
      if (attr.column == field) {
        result = n;
        return;
      }
    });

    return result;
  }

  // Get the fields of an object in string form
  Iterable get fields {
    // Return from the cache if its in there
    if (_fieldCache.containsKey(entity.runtimeType))
      return _fieldCache[entity.runtimeType];

    var results = _reflectee.type.declarations;
    var fields = [];

    results.forEach((field, instance) {
      if (instance is VariableMirror) fields.add(MirrorSystem.getName(field));
    });

    return _fieldCache[entity.runtimeType] = fields;
  }

  // Ugh, get a field type out via query
  String _getType(field) {
    var result = fields.firstWhere((f) => f == field);

    return result.runtimeType.toString();
  }
}
