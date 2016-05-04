import 'runnable.dart';
import '../query_chain.dart';
import '../query_token.dart';
import '../query_runner.dart';

/// Defines a [QueryToken] class which can identified by the [id] method
class Identifier extends QueryToken {
  Identifier(QueryChain chain) : super(chain);

  /// Takes an [id] and returns the [QueryChain]
  SingleResultRunnable id(id) => init('id', id, new QueryRunner(chain));
}
