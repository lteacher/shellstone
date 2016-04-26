part of shellstone;

/// There is some serious hackery about to occur in here but it is for a good
/// cause (I promise). There are impl classes that drop below multiple interfaces because
/// the code is safe though dynamic, we want the type system to show the user
/// the different methods for Future or Stream. Unfortunately to actually
/// do this without the hack means duplication of logic, so instead
/// the logic is not duplicated but there is an impl class at the end
/// of the hierarchy in some cases like [Query] with ambiguous types implementation

/// A Runnable class
abstract class Runnable {
  dynamic run();
}

/// Defines a [Runnable] which returns a [Future] with the single result
abstract class SingleResultRunnable extends Runnable {
  /// Runs the query chain producing an async result
  Future<dynamic> run();
}

/// Defines a [Runnable] which returns a [Stream] of multiple results
abstract class MultipleResultRunnable extends Runnable {
  /// Runs the query chain producing a Stream of async results
  Stream<dynamic> run();
}

/// Query class that produces single result chains
abstract class SingleResultQuery implements SingleResultRunnable {
  /// Takes a [List] OR single [fields] and returns a new [SingleResultFilter]
  SingleResultFilter where(fields);
}

/// Query class that produces multiple result chains
abstract class MultipleResultQuery implements MultipleResultRunnable {
  /// Takes a [List] OR single [fields] and returns the a new [MultipleResultFilter]
  MultipleResultFilter where(fields);
}

// Implements the query class
class Query extends Chainable
    implements SingleResultQuery, MultipleResultQuery {
  Query(QueryChain chain) : super(chain);

  // Sets up the query object as a where condition
  where(fields) => _init('where', fields, new Filter(_chain));

  /// Concrete run
  run() => _run();
}

/// Selector class for and / or operations as part of a single result chain
abstract class SingleResultSelector {
  SingleResultFilter and(fields);
  SingleResultFilter or(fields);
}

/// Produces multiple result filter objects
abstract class MultipleResultSelector {
  MultipleResultFilter and(fields);
  MultipleResultFilter or(fields);
}

/// Concrete Selector implementation
class Selector extends Chainable {
  Selector(QueryChain chain) : super(chain);

  // Setup the selector as either and / or operation in the chain
  and(fields) => _init('and', fields, new Filter(_chain));
  or(fields) => _init('or', fields, new Filter(_chain));
}

/// Produces single result modifier
abstract class SingleResultModifier implements SingleResultRunnable {
  SingleResultModifier sort(direction, fields);
  SingleResultModifier skip(int n);
  SingleResultModifier limit(int n);
}

/// Produces multiple result modifier
abstract class MultipleResultModifier implements MultipleResultRunnable {
  MultipleResultModifier sort(direction, fields);
  MultipleResultModifier skip(int n);
  MultipleResultModifier limit(int n);
}

/// Concrete implementation of the modifier
class Modifier extends Chainable
    implements SingleResultModifier, MultipleResultModifier {
  Modifier(QueryChain chain) : super(chain);

  sort(direction, fields) => _init('sort', fields, new Modifier(_chain));
  skip(n) => _init('skip', n, new Modifier(_chain));
  limit(n) => _init('limit', n, new Modifier(_chain));

  run() => _run();
}

/// Defines a modifier and selector combination for single results
abstract class SingleResultCondition
    implements
        SingleResultModifier,
        SingleResultSelector,
        SingleResultRunnable {}

/// Defines a modifier and selector combination for multiple results
abstract class MultipleResultCondition
    implements
        MultipleResultModifier,
        MultipleResultSelector,
        MultipleResultRunnable {}

// Implements the concrete condition class
class Condition extends Chainable
    implements SingleResultCondition, MultipleResultCondition {
  Condition(QueryChain chain) : super(chain);

  // Selectors
  and(fields) => _init('and', fields, new Filter(_chain));
  or(fields) => _init('or', fields, new Filter(_chain));

  // Modifiers
  sort(direction, fields) => _init('sort', fields, new Modifier(_chain));
  skip(n) => _init('skip', n, new Modifier(_chain));
  limit(n) => _init('limit', n, new Modifier(_chain));

  // Run
  run() => _run();
}

abstract class SingleResultFilter {
  SingleResultCondition eq(values);
  SingleResultCondition ne(values);
  SingleResultCondition lt(values);
  SingleResultCondition gt(values);
  SingleResultCondition le(values);
  SingleResultCondition ge(values);
  SingleResultModifier filter(Function f);
}

abstract class MultipleResultFilter {
  MultipleResultCondition eq(values);
  MultipleResultCondition ne(values);
  MultipleResultCondition lt(values);
  MultipleResultCondition gt(values);
  MultipleResultCondition le(values);
  MultipleResultCondition ge(values);
  MultipleResultModifier filter(Function f);
}

class Filter extends Chainable {
  Filter(QueryChain chain) : super(chain);

  eq(values) => _init('eq', values, new Condition(_chain));
  ne(values) => _init('ne', values, new Condition(_chain));
  lt(values) => _init('lt', values, new Condition(_chain));
  gt(values) => _init('gt', values, new Condition(_chain));
  le(values) => _init('le', values, new Condition(_chain));
  ge(values) => _init('ge', values, new Condition(_chain));
  filter(Function f) => _init('filter', f, new Condition(_chain));
}

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

/// Defines a [Chainable] class which can identified by the [id] method
class Identifier extends Chainable {
  Identifier(QueryChain chain) : super(chain);

  /// Takes an [id] and returns the [QueryChain]
  SingleResultRunnable id(id) => _init('id', id, _chain);
}

/// Represents the collection of [Chainable] objects in the query
///
/// The QueryChain will capture each function into a chain of statements
/// which are then used to pass as tokens to the DataAccess adapter layer
class QueryChain implements SingleResultRunnable, MultipleResultRunnable {
  List<Chainable> _chain = new List();
  ModelAction _action;

  QueryChain(this._action);

  /// Runs the query chain
  run() {
    // Get all the random stuff needed
    Model model = Metadata.model(_action.name);
    var resource = model.resource;
    var dataSource = model.dataSource;
    var dbAdapter = Shellstone.adapters[dataSource];

    // Create a new query adapter for this run
    QueryAdapter q = dbAdapter.getQueryAdapter(_action.type, resource);
    q.db = dbAdapter;

    // For each chainable
    _chain.forEach((c) {
      // Map the token
      q.mapToken(new QueryToken(c.op, c.values));
    });

    // Return the result of the query adapter run
    return q.run();
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
  String name;
  QueryChain _chain;

  // Constructor
  ModelAction(this.name) {
    _chain = new QueryChain(this);
  }

  dynamic _init(type, result) {
    this.type = type;
    return result;
  }

  /// Get a single entity by providing an ID
  Identifier get() => _init('get', new Identifier(_chain));

  /// Find a single entity
  SingleResultQuery find() => _init('find', new Query(_chain));

  /// Find a collection of entities
  MultipleResultQuery findAll() => _init('findAll', new Query(_chain));

  /// Insert a single entity
  SingleResultQuery insert(dynamic entity) =>
      _init('insert', new Query(_chain));

  /// Insert a collection of entities
  SingleResultQuery insertAll(List<dynamic> entities) =>
      _init('insertAll', new Query(_chain));

  /// Update a given entity
  SingleResultQuery update(dynamic entity) =>
      _init('update', new Query(_chain));

  /// Update a collection of entities
  SingleResultQuery updateAll(List<dynamic> entities) =>
      _init('updateAll', new Query(_chain));
}

class QueryToken {
  final String modifier;
  final dynamic values;

  const QueryToken(this.modifier, this.values);
}
