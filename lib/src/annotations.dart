part of shellstone;

/// An annotation to represent the metadata of a Model.
///
/// Essentially the annotation defines a collection or table and the relevant
/// properties for interacting with that particular model
class Model {
  final String identity;
  final String connection;
  final bool autoCreatedAt;
  final bool autoUpdatedAt;

  const Model({
    this.identity,
    this.connection,
    this.autoCreatedAt,
    this.autoUpdatedAt
  });

  /// Takes a Model [name] e.g. 'User' and returns an [Identifier].
  ///
  /// An Identifier provides an [Identifier.id] method which is used to get a
  /// specific [Model] entity by its primary key
  static Identifier get(name) => new ModelAction(name).get();

  /// The [find] method is used to find a *single*, or the *first* matching entity
  static Query find(name) => new ModelAction(name).find();

  /// The [findAll] method is used to find a *all* matching entites
  static Query findAll(name) => new ModelAction(name).findAll();

  // static Query insert(entity) => new ModelAction(name).insert(entity);
  // static Query insertAll(List entities) => new ModelAction(name).insert(List entities);

  // static Query update(entity) => new ModelAction(name).insert(entity);
  // static Query updateAll(List entities) => new ModelAction(name).insert(List entities);
}

/// An annotation to represent the metadata of an Attribute.
///
/// Attributes are fields or columns of a data set. The annotation allows the setting
/// of various options that are used to describe the attribute for interaction
/// at the data access layer.
class Attr {
  final String type;
  final String column;
  final bool primaryKey;

  const Attr({this.type,this.column,this.primaryKey});
}
