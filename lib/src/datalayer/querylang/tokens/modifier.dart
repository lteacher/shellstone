import 'runnable.dart';
import '../query_chain.dart';
import '../query_token.dart';

/// Produces single result modifier
abstract class SingleResultModifier implements SingleResultRunnable {
  SingleResultModifier sort(direction, fields);
  SingleResultModifier skip(int n);
  SingleResultModifier limit(int n);
}

/// Produces multiple result modifier
abstract class MultipleResultModifier implements MultipleResultRunnable {
  MultipleResultModifier sort(direction, fields);
  MultipleResultModifier skip(int n);
  MultipleResultModifier limit(int n);
}

/// Concrete implementation of the modifier
class Modifier extends QueryToken
    implements SingleResultModifier, MultipleResultModifier {
  Modifier(QueryChain chain) : super(chain);

  sort(direction, fields) => init('sort', fields, new Modifier(chain));
  skip(n) => init('skip', n, new Modifier(chain));
  limit(n) => init('limit', n, new Modifier(chain));

  run() => runChain();
}
