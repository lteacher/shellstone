import 'dart:mirrors';
import 'entity_definition.dart';
import 'entity_wrapper.dart';
import '../metadata/annotations.dart';
import '../metadata/metadata.dart';

/// Builds entities and manages their definitions
class EntityBuilder {
  static Map<String, EntityDefinition> _defs = {};

  // Check if a definition is loaded
  static bool isLoaded(String name) => _defs.containsKey(name);

  // Load a entity definition into the entity builder
  static loadDefinition(String name) {
    var proxy = Metadata.get(Model,name);
    loadType(proxy.ref.reflectedType);
  }

  // Load a type into the entity builder
  static loadType(Type t) {
    var def = new EntityDefinition(reflectType(t));

    _defs[def.name] = def;
  }

  // Load a mirror into the entity builder
  static loadMirror(TypeMirror t) {
    var def = new EntityDefinition(t);

    _defs[def.name] = def;
  }

  // Gets the definition for a given name
  static EntityDefinition getDefinition(name) => _defs[name];

  // Create an instance of a given type
  static dynamic createType(Type t, [Map<Symbol, dynamic> fields]) =>
      create(t.toString(), fields);

  // Create an instance by name
  static dynamic create(String name, [Map<Symbol, dynamic> fields]) {
    if (!isLoaded(name)) loadDefinition(name);

    var def = getDefinition(name);

    /// Construct an instance with default constructor.
    var mirror = def.instantiate();
    var instance = mirror.reflectee;

    // If fields are provided then we will set them here
    if (fields != null)
      fields.forEach((field, value) {
      mirror.setField(field, value);
    });

    return instance;
  }

  /// Wraps an [entity] into its mapped [Model] view, e.g. converts it to its annotated
  /// form as a map of key values.
  static Map<String, dynamic> wrap(dynamic entity) =>
      new EntityWrapper(entity).wrap();

  /// Unwraps an entity from its mapped [Model] form.
  static dynamic unwrap(String name, Map<String, dynamic> map) =>
      new EntityWrapper(name).unwrap(map);

  // Get the value of a field on a given entity
  static dynamic getValue(entity,field) {
    var mirror = reflect(entity);
    return mirror.getField(new Symbol(field)).reflectee;
  }

  // Set the value of a field on a given entity
  static dynamic setValue(entity,field,value) {
    var mirror = reflect(entity);
    return mirror.setField(new Symbol(field),value);
  }
}
