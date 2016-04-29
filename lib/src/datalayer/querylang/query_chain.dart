import 'query_action.dart';
import 'query_token.dart';
import '../../metadata/annotations.dart';

/// Represents the collection of [QueryToken] objects in the query
///
/// The QueryChain will capture each function into a chain of statements
/// which are then used to pass as tokens to the DataAccess adapter layer
class QueryChain  {
  List<QueryToken> _chain = new List();
  QueryAction _qryAction;

  QueryChain(this._qryAction);

  /// The query action, e.g. 'findAll'
  String get action => _qryAction.type;

  /// The resource name, e.g. 'user'
  String get resource => _qryAction.model.resource;

  /// A [Model] object for the query
  Model get model => _qryAction.model;

  /// Adds a [QueryToken] to the query chain
  add(QueryToken token) {
    _chain.add(token);
  }

  /// Removes a [QueryToken] from the query chain
  remove(QueryToken token) {
    _chain.remove(token);
  }
}
