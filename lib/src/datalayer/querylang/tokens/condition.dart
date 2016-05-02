import 'modifier.dart';
import 'runnable.dart';
import 'selector.dart';
import 'filter.dart';
import '../query_chain.dart';
import '../query_token.dart';

/// Defines a modifier and selector combination for single results
abstract class SingleResultCondition
    implements
        SingleResultModifier,
        SingleResultSelector,
        SingleResultRunnable {}

/// Defines a modifier and selector combination for multiple results
abstract class MultipleResultCondition
    implements
        MultipleResultModifier,
        MultipleResultSelector,
        MultipleResultRunnable {}

// Implements the concrete condition class
class Condition extends Selector
    implements SingleResultCondition, MultipleResultCondition {
  Condition(QueryChain chain) : super(chain);

  // Modifiers
  sort(direction, fields) => init('sort', fields, new Modifier(chain));
  skip(n) => init('skip', n, new Modifier(chain));
  limit(n) => init('limit', n, new Modifier(chain));

  // Run
  run() => runChain();
}
