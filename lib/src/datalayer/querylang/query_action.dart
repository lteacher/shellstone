import 'query_chain.dart';
import 'tokens/indentifier.dart';
import 'tokens/query.dart';
import 'tokens/runnable.dart';
import 'tokens/insertion.dart';
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
  QueryAction(String name) {
    this.name = name;
    _chain = new QueryChain()..setQueryAction(this);
    model = Metadata.model(name);
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
  SingleResultRunnable insert(dynamic entity) =>
      _init('insert', new Insertion(_chain, [entity]));

  /// Insert a collection of entities
  MultipleResultRunnable insertAll(List<dynamic> entities) =>
      _init('insertAll', new Insertion(_chain, entities));

  /// Update a given entity
  SingleResultRunnable update(dynamic entity) =>
      _init('update', new Query(_chain));

  /// Update a collection of entities
  MultipleResultRunnable updateAll(List<dynamic> entities) =>
      _init('updateAll', new Query(_chain));
}
