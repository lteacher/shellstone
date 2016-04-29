import 'filter.dart';
import '../query_chain.dart';
import '../query_token.dart';

/// Selector class for and / or operations as part of a single result chain
abstract class SingleResultSelector {
  SingleResultFilter and(fields);
  SingleResultFilter or(fields);
}

/// Produces multiple result filter objects
abstract class MultipleResultSelector {
  MultipleResultFilter and(fields);
  MultipleResultFilter or(fields);
}

/// Concrete Selector implementation
class Selector extends QueryToken {
  Selector(QueryChain chain) : super(chain);

  // Setup the selector as either and / or operation in the chain
  and(fields) => init('and', fields, new Filter(chain));
  or(fields) => init('or', fields, new Filter(chain));
}
