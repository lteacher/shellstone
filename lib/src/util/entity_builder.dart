import 'dart:mirrors';
import '../metadata/annotations.dart';
import '../metadata/metadata.dart';

/// Builds an `entity`, which is a class annotated by [Model]
class EntityBuilder {
  // Metadata singleton
  static final EntityBuilder _builder = new EntityBuilder._internal();
  factory EntityBuilder() => _builder;
  EntityBuilder._internal();

  /// Instantiates a given model [name] potentially setting the [fields]
  /// the fields in this case match the fields on the object specifically
  static dynamic create(String name, [Map<Symbol, dynamic> fields]) {
    var proxy = Metadata.get(Model,name);

    /// Construct an instance with default constructor.
    var mirror = proxy.ref.newInstance(const Symbol(''), new List());
    var instance = mirror.reflectee;

    // If fields are provided then we will set them here
    if (fields != null)
      fields.forEach((field, value) {
      mirror.setField(field, value);
    });

    return instance;
  }
}
