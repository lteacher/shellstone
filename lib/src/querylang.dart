part of shellstone;

abstract class Chainable {
  QueryChain _chain;
  String op;
  List values;

  Chainable(this._chain) {
    _chain.add(this);
  }

  // Pass through initializer
  dynamic _init(op,val,result) {
    this.op = op;

    if(val is List) this.values = val;
    else this.values = []..add(val);

    return result;
  }

  // When called here the chain can remove this as its an invalid
  _run() {
    _chain.remove(this);
    return _chain.run();
  }
}

// Things that can be selected
abstract class Selectable { // Filterable
  Filterable and(List<String> fields);
  Filterable or(List<String> fields);
}

// Things that can be filtered
abstract class Filterable { // Select or Run
  Condition eq(List values);
  Condition ne(List values);
  Condition gt(List values);
  Condition lt(List values);
  Condition le(List values);
  Condition ge(List values);
}

// Things that can be constrained such as limiting or filter function
abstract class Constrainable {
  Runnable filter(Function f);
  Constraint limit(int value);
}

// Things that can call run()
abstract class Runnable {
  Future run();
}

class Constraint extends Chainable implements Constrainable, Runnable {
  Constraint(QueryChain chain) : super(chain);

  Constraint limit(value) => _init('limit',value, new Constraint(_chain));
  Runnable filter(f) => _init('filter',f, _chain);
  Future run() => _run();
}

class Identifier extends Chainable {
  Identifier(QueryChain chain) : super(chain);

  Runnable id(id) => _init('id',id, _chain);
}

// An initial selection
class Query extends Chainable implements Runnable {
  Query(QueryChain chain) : super(chain);

  Filter where(List<String> fields) => _init('where',fields,new Filter(_chain));
  Future run() => _run();
}

// Filter class
class Filter extends Chainable implements Filterable {
  Filter(QueryChain chain) : super(chain);

  Condition eq(values) => _init('eq',values,new Condition(_chain));
  Condition ne(values) => _init('ne',values,new Condition(_chain));
  Condition gt(values) => _init('gt',values,new Condition(_chain));
  Condition lt(values) => _init('lt',values,new Condition(_chain));
  Condition ge(values) => _init('ge',values,new Condition(_chain));
  Condition le(values) => _init('le',values,new Condition(_chain));
}

// Condition is Chainable, inherits run, filter and limit. Implements and / or
class Condition extends Constraint implements Selectable {
  Condition(QueryChain chain) : super(chain);

  Filter and(fields) => _init('and',fields,new Filter(_chain));
  Filter or(fields) => _init('or',fields,new Filter(_chain));
}

/// Represents the query structure in order
class QueryChain implements Runnable {
  List<Chainable> _chain = new List();
  ModelAction _action;

  QueryChain(this._action);

  Future run() {
    return new Future.value(_chain);
  }

  add(Chainable c) {
    _chain.add(c);
  }

  remove(Chainable c) {
    _chain.remove(c);
  }
}

/// Defines an action for a given model
class ModelAction {
  String type;
  String _model;
  QueryChain _chain;

  // Constructor
  ModelAction(this._model) {
    _chain = new QueryChain(this);
  }

  dynamic _init(type,result) {
    this.type = type;
    return result;
  }

  /// Get a single entity by providing an ID
  Identifier get() => _init('get',new Identifier(_chain));

  /// Find a single entity
  Query find() => _init('find',new Query(_chain));

  /// Find a collection of entities
  Query findAll() => _init('findAll',new Query(_chain));

  /// Insert a single entity
  Query insert(dynamic entity) => _init('insert',new Query(_chain));

  /// Insert a collection of entities
  Query insertAll(List<dynamic> entities) => _init('insertAll',new Query(_chain));

  /// Update a given entity
  Query update(dynamic entity) => _init('update',new Query(_chain));

  /// Update a collection of entities
  Query updateAll(List<dynamic> entities) => _init('updateAll',new Query(_chain));
}
