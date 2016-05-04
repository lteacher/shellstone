import 'package:collection/collection.dart';
import 'query_action.dart';
import 'query_token.dart';
import '../../metadata/annotations.dart';

/// Represents the collection of [QueryToken] objects in the query
///
/// The QueryChain will capture each function into a chain of statements
/// which are then used to pass as tokens to the DataAccess adapter layer
class QueryChain<QueryToken> extends DelegatingList<QueryToken> {
  final List<QueryToken> _chain;
  QueryAction _qryAction;

  QueryChain() : this._(<QueryToken>[]);
  QueryChain._(chain)
      : _chain = chain,
        super(chain);

  /// Sets the [QueryAction] since its easier for now than messing with the
  /// delegate stuff.
  setQueryAction(QueryAction qryAction) {
    _qryAction = qryAction;
  }

  /// The query action, e.g. 'findAll'
  String get action => _qryAction.type;

  /// The resource name, e.g. 'user'
  String get resource => _qryAction.model.resource;

  /// A [Model] object for the query
  Model get model => _qryAction.model;

  /// Get the name of an annotated model `entity` for example `User`
  String get entity => _qryAction.name;
}
