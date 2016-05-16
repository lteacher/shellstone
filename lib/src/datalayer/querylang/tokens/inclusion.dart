import 'query.dart';
import '../query_chain.dart';
import '../query_token.dart';
import '../query_runner.dart';
import '../query_action.dart';

/// Defines a class which specifies an included relation on the chain
class Inclusion extends QueryToken {
  Inclusion(QueryChain chain) : super(chain);

  /// Takes an [id] and returns the [QueryChain]
  MultipleResultQuery incl(String name) {
    //
    // var action = new QueryAction('User');
  }
}
