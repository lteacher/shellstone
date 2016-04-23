part of shellstone;

class Chainable {
  QueryChain _chain;
  Chainable(this._chain);
}

// Things that can be selected
abstract class Selectable { // Filterable
  Filterable and(List<String> fields);
  Filterable or(List<String> fields);
}

// Things that can be filtered
abstract class Filterable { // Select or Run
  Condition eq(List values);
  Condition gt(List values);
  Condition lt(List values);
  Runnable filter(Function f);
  Runnable limit(int value);
}

class Identifier extends Chainable {
  Identifier(QueryChain chain) : super(chain);

  Runnable id(id) => _chain;
}

// Things that can call run()
abstract class Runnable {
  Future run();
}

// An initial selection
class Query extends Chainable implements Runnable {
  Query(QueryChain chain) : super(chain);

  Filter where(List<String> fields) => new Filter(_chain);
  run() => _chain.run();
}

// Filter class
class Filter extends Chainable implements Filterable {
  Filter(QueryChain chain) : super(chain);

  eq(values) => new Condition(_chain);
  gt(values) => new Condition(_chain);
  lt(values) => new Condition(_chain);
  filter(f) => _chain;
  limit(f) => _chain;
}

// TODO: Cleanup
class Condition extends Chainable implements Selectable, Runnable {
  Condition(QueryChain chain) : super(chain);

  and(fields) => new Filter(_chain);
  or(fields) => new Filter(_chain);

  run() => _chain.run();
}

// Query chain
class QueryChain implements Runnable {
  List<Chainable> _chain;

  Future run() {
    return new Future.value('Enjoy');
  }

  add(Chainable c) {
    _chain.add(c);
  }
}

class ModelAction {
  String _model;
  QueryChain _chain;

  // Constructor
  ModelAction(this._model) {
    _chain = new QueryChain();
  }

  // // Get a single entity by id DOESNT LOOK GOOD HERE
  // static Identifier get(String model) {
  //   ModelAction qry = new ModelAction(model);
  //   return new Identifier(qry._chain);
  // }

  /// Find a single entity
  Query find() {}

  /// Find a collection of entities
  Query findAll() {}

  /// Insert a single entity
  Query insert(dynamic entity) {}

  /// Insert a collection of entities
  Query insertAll(List<dynamic> entities) {}

  /// Update a given entity
  Query update(dynamic entity) {}

  /// Update a collection of entities
  Query updateAll(List<dynamic> entities) {}





}
