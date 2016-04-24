part of shellstone;

/// This annotation defines a Model which generally represents a table of
/// collection.
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

  static Identifier get(name) => new ModelAction(name).get();
  static Query find(name) => new ModelAction(name).find();
  static Query findAll(name) => new ModelAction(name).findAll();

  // static Query insert(entity) => new ModelAction(name).insert(entity);
  // static Query insertAll(List entities) => new ModelAction(name).insert(List entities);

  // static Query update(entity) => new ModelAction(name).insert(entity);
  // static Query updateAll(List entities) => new ModelAction(name).insert(List entities);
}

/// This annotation defines an attribute which is essentially the columns,
/// however, you can add additional properties.
class Attr {
  final String type;
  final String column;
  final bool primaryKey;

  const Attr({this.type,this.column,this.primaryKey});
}
