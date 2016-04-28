part of shellstone;

class EntityBuilder {
  // Metadata singleton
  static final EntityBuilder _builder = new EntityBuilder._internal();
  factory EntityBuilder() => _builder;
  EntityBuilder._internal();

  /// Instantiates a given model [name] potentially setting the [fields]
  /// the fields in this case match the fields on the object specifically
  static dynamic create(String name, [Map<Symbol, dynamic> fields]) {
    var proxy = Metadata.proxy('model',name);

    /// Construct an instance with default constructor.
    var instance =
        proxy.ref.newInstance(const Symbol(''), new List()).reflectee;

    // If fields are provided then we will set them here
    if (fields != null)
      fields.forEach((field, value) {
      smoke.write(instance, field, value);
    });

    return instance;
  }
}

/// Wraps an entity up to match its metadata [Model] and [Attr] descriptors
///
/// The class can also be accessed by using the [Metadata.wrap] and [Metada.unwrap]
/// methods just for convenience sake.
class EntityWrapper {
  dynamic entity;
  String name;
  Map attributes;

  /// At least [entity] or [name] must be provided on construction
  EntityWrapper({this.entity, this.name}) {
    if (entity == null && name == null)
      throw 'At least one arg must be provided to the EntityWrapper';

    if (entity == null) entity = EntityBuilder.create(name);
    if (name == null) name = Metadata.name(entity);
    attributes = Metadata.attr(name);
  }

  /// Wraps an [entity] into its mapped [Model] view, e.g. converts it to its annotated
  /// form as a map of key values.
  Map<String, dynamic> wrap() {
    var result = {};

    // For each field
    _fields.where(attributes.containsKey).forEach((field) {
      Attr attr = attributes[field];

      // Set the property name
      var property = attr.column != null ? attr.column : field;
      var value = smoke.read(entity, new Symbol(field));

      // If the value is not null set it
      if (value != null) result[property] = _coerceType(attr.type, value);
    });

    return result;
  }

  /// Unwraps an [entity] from its mapped [Model] form.
  dynamic unwrap(Map<String, dynamic> map) {
    map.forEach((f,value) {
      // Get the attribute we need
      var field = _getAttrField(f);

      if (field != null) {
        var type = _getType(field);

        smoke.write(entity, new Symbol(field), _coerceType(type,value));
      }
    });

    return entity;
  }

  // Convert some type, this is primitive. TODO: Do something better here
  _coerceType(type, value) {
    switch (type) {
      case 'string':
      case 'String':
        return value.toString();
      case 'integer':
      case 'int':
        return int.parse(value);
    }
  }

  // Gets the annotated field on the class
  // Need to think of a way to make this more efficient!!
  String _getAttrField(field) {
    // If this field is in the attributes then it can be returned directly
    if (attributes.containsKey(field)) return field;

    // Otherwise we need to search for the column which sucks big time
    var result;
    attributes.forEach((n,attr) {
      if (attr.column == field) {
        result = n;
        return;
      }
    });

    return result;
  }

  // Get the fields of an object in string form
  Iterable get _fields {
    return smoke.query(entity.runtimeType, const smoke.QueryOptions())
        .map((f) => smoke.symbolToName(f.name));
  }

  // Ugh, get a field type out via smoke.query
  String _getType(field) {
    var result = smoke.query(entity.runtimeType, new smoke.QueryOptions(matches: (Symbol name) {
      return name == new Symbol(field);
    }));

    return result[0].type.toString();
  }
}
