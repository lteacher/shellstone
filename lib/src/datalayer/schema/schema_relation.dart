import 'schema.dart';
// import '../../metadata/annotations.dart';
import '../../metadata/metadata_proxies.dart';
import '../../entities/entity_builder.dart';
import '../../entities/entity_definition.dart';


/// Represents a relation in the schema,
class SchemaRelation {
  Schema _schema;
  String name;
  RelWrapper _rel;
  EntityDefinition _def;

  SchemaRelation(this._schema, this.name, this._rel) {
    _def = EntityBuilder.getDefinition(_schema.name);
  }

  // Getters
  get model => _rel.model;
  get by => _rel.by ?? _schema.primaryKey.name;
  get as => _rel.as ?? '${_schema.resource}_${_schema.primaryKey.column}';
  get isCollection => _rel.isCollection;
  get modelName => _rel.model.toString();

  // TODO: Need some kind of enum for relations to indicate easily oneToMany etc.
  // get type

  // TODO: This is relevant only for a many to many
  // get via =>
}
