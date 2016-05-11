import 'metadata.dart';
import 'metadata_proxies.dart';
import '../datalayer/querylang.dart';
import '../events/event_registration.dart';

/// An annotation to represent the metadata of a Model.
///
/// Essentially the annotation defines a collection or table and the relevant
/// properties for interacting with that particular model
class Model {
  /// The name of the table or collection
  final String name;

  /// The name of the source, e.g. `mysql`, or `mongo` or even `customSrc`
  final String source;

  /// The form of migration strategy, currently supported are `safe` and `drop`
  final String migration;

  // Coming later, this indicates that the model doesn't require a schema?
  // but first it requires the user to extend the BaseModel
  final bool schema = true;

  /// Constructs a [Model] const with the given values
  const Model({this.name, this.source, this.migration:'safe'});

  /// Takes a Model [name] e.g. 'User' and returns an [Identifier].
  ///
  /// An Identifier provides an [Identifier.id] method which is used to get a
  /// specific [Model] entity by its primary key
  static Identifier get(Type t) => new QueryAction(_modelName(t)).get();

  /// The [find] method is used to find a *single*, or the *first* matching entity
  static SingleResultQuery find(Type t) => new QueryAction(_modelName(t)).find();

  /// The [findAll] method is used to find a *all* matching entites
  static MultipleResultQuery findAll(Type t) => new QueryAction(_modelName(t)).findAll();

  /// The [findByName] is the same as [find] but using the model name
  static SingleResultQuery findByName(String name) => new QueryAction(name).find();

  /// The [findAllByName] method is used to find a *all* matching entites by model name
  static MultipleResultQuery findAllByName(String name) => new QueryAction(name).findAll();

  /// The [insert] method is used to insert a given set of values
  static SingleResultRunnable insert(Type t, Map values) =>
      new QueryAction(_modelName(t)).insert(values);

  /// The [insertByName] is the same as [insert] but by model name
  static SingleResultRunnable insertByName(String name, Map values) =>
      new QueryAction(name).insert(values);

  /// The [insertFrom] method inserts from an entity or collection of entities
  static SingleResultRunnable insertFrom(entities) =>
      new QueryAction(Metadata.name(entities)).insertFrom(entities);

  /// The [update] method is used to update an entity where matches
  static SingleResultQuery update(Type t,Map values) =>
      new QueryAction(_modelName(t)).update(values);

  /// The [updateByName] is the same as [update] but for a model name
  static SingleResultQuery updateByName(String name,Map values) =>
      new QueryAction(name).update(values);

  /// The [updateFrom] method updates from the given entity or entities
  static SingleResultRunnable updateFrom(entities) =>
      new QueryAction(Metadata.name(entities)).updateFrom(entities);

  /// The [remove] method is used to remove matching values
  static SingleResultQuery remove(Type t,Map values) =>
      new QueryAction(_modelName(t)).remove(values);

  /// The [removeByName] method is used to remove matching for a model name
  static SingleResultQuery removeByName(String name,Map values) =>
      new QueryAction(name).remove(values);

  /// The [removeFrom] method is used to insert a given entity or entity col
  static SingleResultRunnable removeFrom(entities) =>
      new QueryAction(Metadata.name(entities)).removeFrom(entities);

  // Shortcut to model name from type
  static String _modelName(Type t) => Metadata.get(ModelMetadata, t).model.name;
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
  final bool unique;
  final int length;
  final bool index;
  final bool autoIncr;

  /// The const constructor for the [Attr] class
  ///
  /// - [type] is the data type, e.g. string. It defaults to being inferred
  /// - [column] is the field name or column name in some collection / table
  /// - [primaryKey] is true if this field is a primary key
  /// - [unique] is true if this field should be unique
  /// - [length] is the length that a field should take up in the DB,
  /// ignored if not supported in the underlying db
  /// - [autoIncr] is set to true if you want the field to auto increment
  const Attr(
      {this.type,
      this.column,
      this.primaryKey: false,
      this.unique: false,
      this.index: false,
      this.length,
      this.autoIncr:false});
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

  static const EventRegistration configure =
      const EventRegistration(Adapter, 'configure');
  static const EventRegistration connect =
      const EventRegistration(Adapter, 'connect');
  static const EventRegistration build =
      const EventRegistration(Adapter, 'build');
  static const EventRegistration disconnect =
      const EventRegistration(Adapter, 'disconnect');
  // static const EventRegistration query = const EventRegistration(Adapter,'query');
}

/// Defines a [Handler] such as a [Hook] or a [Listen]er
abstract class Handler {
  final String loc;
  final EventRegistration reg;

  const Handler(this.reg, [this.loc = 'pre']);
}

/// An annotation to set a listener for a particular event
///
/// [Listen]ers are functions that are notified via [BroadcastStream]
/// and are generally for notification as they are fired off async
class Listen extends Handler {
  const Listen(EventRegistration reg) : super(reg);
  const Listen.pre(EventRegistration reg) : super(reg);
  const Listen.post(EventRegistration reg) : super(reg, 'post');
}

/// An annotation to set a hook in for a particular event
///
/// [Hooks] are functions that are called like intercepters pre or post
/// something happening. They provide the opportunity to manipulate something
/// similar to a map function.
class Hook extends Handler {
  const Hook(EventRegistration reg) : super(reg);
  const Hook.pre(EventRegistration reg) : super(reg);
  const Hook.post(EventRegistration reg) : super(reg, 'post');
}
