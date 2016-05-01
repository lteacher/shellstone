import 'metadata.dart';
import '../datalayer/querylang.dart';

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
  static Identifier get(name) => new QueryAction(name).get();

  /// The [find] method is used to find a *single*, or the *first* matching entity
  static SingleResultQuery find(name) => new QueryAction(name).find();

  /// The [findAll] method is used to find a *all* matching entites
  static MultipleResultQuery findAll(name) => new QueryAction(name).findAll();

  /// The [insert] method is used to insert a given entity
  static SingleResultRunnable insert(entity) =>
      new QueryAction(Metadata.name(entity)).insert(entity);

  /// The [insertAll] method inserts all the entities in the collection
  static MultipleResultRunnable insertAll(List entities) =>
      new QueryAction(Metadata.name(entities)).insertAll(entities);

  /// The [update] method is used to update an entity if it exists
  static SingleResultQuery update(entity) =>
      new QueryAction(Metadata.name(entity)).insert(entity);

  /// The [updateAll] method updates all of the entities in the [entities] colllection
  static MultipleResultQuery updateAll(List entities) =>
      new QueryAction(Metadata.name(entities)).insertAll(entities);
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
/// Adapter metadata corresponds to the [DatabaseAdapter] class and provide the
/// capability to make adjustments at runtime to the relevant Database Adapters.
///
/// Your class **must** extend the [DatabaseAdapter] else it will fail to load
class Adapter {
  final String name;

  /// The [name] is the database name, for exampe 'mongo' or 'mysql' etc
  const Adapter(this.name);

  /// Adapter events ? coming soon
  // final AdapterEvent configure = const AdapterEvent();
}

/// An annotation to set a listener for a particular event
class Listen {
  const Listen();
  const Listen.pre();
  const Listen.post();
}
