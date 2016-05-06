import 'dart:mirrors';

// Represents an entity that is annotated by a model
class EntityDefinition {
  Map<String, Type> fields = {};
  ClassMirror _mirror;

  EntityDefinition(this._mirror) {
    _mirror.declarations.forEach((sym, d) {
      if (d is VariableMirror) {
        var name = MirrorSystem.getName(sym);
        var type = d.type.reflectedType;
        fields[name] = type;
      }
    });
  }

  // Instantiates the underlying instance
  InstanceMirror instantiate() => _mirror.newInstance(const Symbol(''), new List());

  // Get the field names
  get fieldNames => fields.keys;

  // Get a field type
  Type fieldType(String name) => fields[name];

  // Get the entity name
  get name => MirrorSystem.getName(_mirror.simpleName);
}
