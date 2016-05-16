import 'query_chain.dart';
import 'tokens/indentifier.dart';
import 'tokens/query.dart';
import 'tokens/runnable.dart';
import 'tokens/insertion.dart';
import 'tokens/removal.dart';
import 'tokens/update.dart';
import '../../metadata/annotations.dart';
import '../../metadata/metadata.dart';

/// Defines an action for a given model
///
/// For example, the model action would be the encapsulating object which indicates
/// to the query chain that this action is a 'find' or other example.
class QueryAction {
  String type;
  String name;
  Model model;
  QueryChain _chain;

  // Constructor
  QueryAction(String name,[this._chain]) {
    this.name = name;
    model = Metadata.model(name);
    if (_chain == null) _chain = new QueryChain()..setQueryAction(this);
    else _chain.setQueryAction(this);
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

  /// Insert a set of values
  SingleResultRunnable insert(values) =>
      _init('insert', new Insertion(_chain, values));

  SingleResultRunnable insertFrom(entities) =>
      _init('insertFrom', new Insertion(_chain, entities));

  /// Update a given entity
  SingleResultQuery update(values) =>
      _init('update', new UpdateQuery(_chain, values));

  /// Update a collection of entities
  SingleResultRunnable updateFrom(entities) =>
      _init('updateFrom', new Update(_chain, entities));

  /// Remove a single entity
  SingleResultQuery remove() =>
      _init('remove', new RemovalQuery(_chain, []));

  /// Remove a collection of entities
  SingleResultRunnable removeFrom(entities) =>
      _init('removeFrom', new Removal(_chain, entities));
}
