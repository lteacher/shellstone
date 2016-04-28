part of shellstone;

/// An annotation to represent the metadata of a Model.
///
/// Essentially the annotation defines a collection or table and the relevant
/// properties for interacting with that particular model
class Model {
  final String resource;
  final String dataSource;
  final bool autoCreatedAt;
  final bool autoUpdatedAt;

  const Model(this.resource,
      {this.dataSource: 'mysql',
      this.autoCreatedAt: true,
      this.autoUpdatedAt: true});

  /// Takes a Model [name] e.g. 'User' and returns an [Identifier].
  ///
  /// An Identifier provides an [Identifier.id] method which is used to get a
  /// specific [Model] entity by its primary key
  static Identifier get(name) => new ModelAction(name).get();

  /// The [find] method is used to find a *single*, or the *first* matching entity
  static SingleResultQuery find(name) => new ModelAction(name).find();

  /// The [findAll] method is used to find a *all* matching entites
  static MultipleResultQuery findAll(name) => new ModelAction(name).findAll();

  /// The [insert] method is used to insert a given entity
  static SingleResultQuery insert(entity) =>
      new ModelAction(Metadata.name(entity)).insert(entity);

  /// The [insertAll] method inserts all the entities in the collection
  static SingleResultQuery insertAll(List entities) =>
      new ModelAction(Metadata.name(entities)).insertAll(entities);

  /// The [update] method is used to update an entity if it exists
  static SingleResultQuery update(entity) =>
      new ModelAction(Metadata.name(entity)).insert(entity);

  /// The [updateAll] method updates all of the entities in the [entities] colllection
  static SingleResultQuery updateAll(List entities) =>
      new ModelAction(Metadata.name(entities)).insertAll(entities);
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

  const Attr({this.type, this.column, this.primaryKey});
}

/// An annotation to indicate the existence of a Database Adapter
///
/// Database Adapters correspond to the [DatabaseAdapter] class and provide the
/// capability to make adjustments at runtime to the provided Database Adapters.
/// actually if your class extends the [DatabaseAdapter] then it will be used
/// as a drop in replacement, whereas otherwise it need annotations for each
/// event handler
class DBAdapter {
  final String name;

  /// The [name] is the database name, for exampe 'mongo' or 'mysql' etc
  const DBAdapter(this.name);
}

/// Abstract Event annotation class
abstract class DBEventMeta {
  final String name; // Might not need this but just to be safe

  const DBEventMeta([this.name]);
}

/// An annotation to indicate a database event called 'configure'
class ConfigureMeta extends DBEventMeta {
  const ConfigureMeta() : super('configure');
}

const configure = const ConfigureMeta();

/// An annotation to indicate a database event called 'connect'
class ConnectMeta extends DBEventMeta {
  const ConnectMeta() : super('connect');
}

const connect = const ConnectMeta();

/// An annotation to indicate a database event called 'build'
class BuildMeta extends DBEventMeta {
  const BuildMeta() : super('build');
}
const build = const BuildMeta();

// /// An annotation to indicate a database event called 'query'
// class QueryMeta extends DBEventMeta {
//   const QueryMeta() : super('query');
// }
// 
// const query = const QueryMeta();

/// An annotation to indicate a database event called 'disconnect'
class DisconnectMeta extends DBEventMeta {
  const DisconnectMeta() : super('disconnect');
}

const disconnect = const DisconnectMeta();

/// An annotation to indicate a database event called 'error'
class ErrorMeta extends DBEventMeta {
  const ErrorMeta() : super('error');
}

const error = const ErrorMeta();
