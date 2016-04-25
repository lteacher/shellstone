part of shellstone;

/// Defines a class which can be included in a [QueryChain]
///
/// Essentially the classes here are all part of a Query
abstract class Chainable {
  QueryChain _chain;
  String op;
  List values;

  /// Takes a single [QueryChain] as am argument
  Chainable(this._chain) {
    _chain._add(this);
  }

  // Allows conveniently setting the operator, values and returning the result
  dynamic _init(op, val, result) {
    this.op = op;

    if (val is List)
      this.values = val;
    else
      this.values = []..add(val);

    return result;
  }

  // Calls the QueryChain run() method but also removes this chainable
  // from the chain as it will have a null operator
  _run() {
    _chain._remove(this);
    return _chain.run();
  }
}

/// Defines a class which can be a selector
///
/// The [and] method and [or] methods can be implemented for this type
abstract class Selectable {
  Filterable and(List<String> fields);
  Filterable or(List<String> fields);
}

/// Defines a class which can be a filter
///
/// A [Filterable] is generally a logical operator
abstract class Filterable {
  Condition eq(List values);
  Condition ne(List values);
  Condition gt(List values);
  Condition lt(List values);
  Condition le(List values);
  Condition ge(List values);
}

/// Defines a class which can act as some kind of a constraint
///
/// This may disappear in later versions, but for the moment it
/// defines the [filter] and [limit] methods
abstract class Constrainable {
  Runnable filter(Function f);
  Constraint limit(int value);
}

/// Defines a class which can be considered runnable
abstract class Runnable {
  Future run();
}

/// A concrete implementation of the [filter] and [limit] methods.
class Constraint extends Chainable implements Constrainable, Runnable {
  Constraint(QueryChain chain) : super(chain);

  /// Takes an int [value] and returns a [new Constraint]
  Constraint limit(int value) => _init('limit', value, new Constraint(_chain));

  /// Takes a [Function] [f] and returns a [QueryChain] which can then be ran
  Runnable filter(f) => _init('filter', f, _chain);

  /// Executes the [QueryChain.run] method
  Future run() => _run();
}

/// Defines a [Chainable] class which can identified by the [id] method
class Identifier extends Chainable {
  Identifier(QueryChain chain) : super(chain);

  /// Takes an [id] and returns the [QueryChain]
  Runnable id(id) => _init('id', id, _chain);
}

/// Defines a [Chainable] class which implements the [Query.where] method and [QueryChain.run]
class Query extends Chainable implements Runnable {
  Query(QueryChain chain) : super(chain);

  /// Takes a [List] OR single [fields] and returns the a [new Filter]
  Filter where(fields) => _init('where', fields, new Filter(_chain));

  /// Executes the [QueryChain.run] method
  Future run() => _run();
}

/// Defines a class which implements the various [Filterable] methods
class Filter extends Chainable implements Filterable {
  Filter(QueryChain chain) : super(chain);

  /// Takes a single or list of values to check if *equals*
  Condition eq(values) => _init('eq', values, new Condition(_chain));

  /// Takes a single or list of values to check if *not equals*
  Condition ne(values) => _init('ne', values, new Condition(_chain));

  /// Takes a single or list of values to check if *greater than*
  Condition gt(values) => _init('gt', values, new Condition(_chain));

  /// Takes a single or list of values to check if *less than*
  Condition lt(values) => _init('lt', values, new Condition(_chain));

  /// Takes a single or list of values to check if *greater than or equal to*
  Condition ge(values) => _init('ge', values, new Condition(_chain));

  /// Takes a single or list of values to check if *less than or equal to*
  Condition le(values) => _init('le', values, new Condition(_chain));
}

/// Condition is [Chainable], inherits [Constraint.run], [Constraint.filter] and [Constraint.limit].
/// Implements [Selectable.and] / [Selectable.or]
class Condition extends Constraint implements Selectable {
  Condition(QueryChain chain) : super(chain);

  /// Takes single or list of [fields] to set as a logical *and*
  Filter and(fields) => _init('and', fields, new Filter(_chain));

  /// Takes single or list of [fields] to set as a logical *or*
  Filter or(fields) => _init('or', fields, new Filter(_chain));
}

/// Represents the collection of [Chainable] objects in the query
///
/// The QueryChain will capture each function into a chain of statements
/// which are then used to pass as tokens to the DataAccess adapter layer
class QueryChain implements Runnable {
  List<Chainable> _chain = new List();
  ModelAction _action;

  QueryChain(this._action);

  /// Runs the query chain
  Future run() {
    return new Future.value(_chain);
  }

  /// Adds a [Chainable] to the query chain
  _add(Chainable c) {
    _chain.add(c);
  }

  _remove(Chainable c) {
    _chain.remove(c);
  }
}

/// Defines an action for a given model
///
/// For example, the model action would be the encapsulating object which indicates
/// to the query chain that this action is a 'find' or other example.
class ModelAction {
  String type;
  String _model;
  QueryChain _chain;

  // Constructor
  ModelAction(this._model) {
    _chain = new QueryChain(this);
  }

  dynamic _init(type, result) {
    this.type = type;
    return result;
  }

  /// Get a single entity by providing an ID
  Identifier get() => _init('get', new Identifier(_chain));

  /// Find a single entity
  Query find() => _init('find', new Query(_chain));

  /// Find a collection of entities
  Query findAll() => _init('findAll', new Query(_chain));

  /// Insert a single entity
  Query insert(dynamic entity) => _init('insert', new Query(_chain));

  /// Insert a collection of entities
  Query insertAll(List<dynamic> entities) =>
      _init('insertAll', new Query(_chain));

  /// Update a given entity
  Query update(dynamic entity) => _init('update', new Query(_chain));

  /// Update a collection of entities
  Query updateAll(List<dynamic> entities) =>
      _init('updateAll', new Query(_chain));
}
