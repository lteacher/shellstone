import 'query_chain.dart';
import 'query_runner.dart';

/// There are impl classes that drop below multiple interfaces because
/// the code is safe though dynamic, we want the type system to show the user
/// the different methods for Future or Stream. Unfortunately to actually
/// do this without the hack means duplication of logic, so instead
/// the logic is not duplicated but there is an impl class at the end
/// of the hierarchy in some cases like [Query] with ambiguous types implementation

/// Defines a class which can be included in a [QueryChain]
///
/// Essentially the classes here are all part of a Query
abstract class QueryToken {
  QueryChain _chain;
  String operator;
  List args;

  /// Takes a single [QueryChain] as an argument
  QueryToken(this._chain);

  // Allows conveniently setting the operator, values and returning the result
  dynamic init(op, val, result) {
    this._chain.add(this);
    this.operator = op;

    if (val is List)
      this.args = val;
    else
      this.args = []..add(val);

    return result;
  }

  runChain() => new QueryRunner(chain).run();

  get chain => _chain;
}
