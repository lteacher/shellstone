import 'filter.dart';
import 'runnable.dart';
import '../query_chain.dart';
import '../query_token.dart';

/// Query class that produces single result chains
abstract class SingleResultQuery implements SingleResultRunnable {
  /// Takes a [List] OR single [fields] and returns a new [SingleResultFilter]
  SingleResultFilter where(fields);
}

/// Query class that produces multiple result chains
abstract class MultipleResultQuery implements MultipleResultRunnable {
  /// Takes a [List] OR single [fields] and returns the a new [MultipleResultFilter]
  MultipleResultFilter where(fields);
}

// Implements the query class
class Query extends QueryToken
    implements SingleResultQuery, MultipleResultQuery {
  Query(QueryChain chain) : super(chain);

  // Sets up the query object as a where condition
  where(fields) => init('where', fields, new Filter(chain));

  /// Concrete run
  run() => runChain();
}
