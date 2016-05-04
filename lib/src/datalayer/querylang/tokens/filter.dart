import 'condition.dart';
import 'modifier.dart';
import '../query_chain.dart';
import '../query_token.dart';

/// A filter for some single result [QueryAction]
abstract class SingleResultFilter {
  SingleResultCondition eq(values);
  SingleResultCondition ne(values);
  SingleResultCondition lt(values);
  SingleResultCondition gt(values);
  SingleResultCondition le(values);
  SingleResultCondition ge(values);
}

/// A filter for some multiple result [QueryAction]
abstract class MultipleResultFilter {
  MultipleResultCondition eq(values);
  MultipleResultCondition ne(values);
  MultipleResultCondition lt(values);
  MultipleResultCondition gt(values);
  MultipleResultCondition le(values);
  MultipleResultCondition ge(values);
}

/// A query token
class Filter extends QueryToken {
  Filter(QueryChain chain) : super(chain);

  eq(values) => init('eq', values, new Condition(chain));
  ne(values) => init('ne', values, new Condition(chain));
  lt(values) => init('lt', values, new Condition(chain));
  gt(values) => init('gt', values, new Condition(chain));
  le(values) => init('le', values, new Condition(chain));
  ge(values) => init('ge', values, new Condition(chain));
}
