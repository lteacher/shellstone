import 'query_chain.dart';
import 'tokens/runnable.dart';
import '../../../shellstone.dart'; // Ugh hmmm

class QueryRunner implements SingleResultRunnable, MultipleResultRunnable {
  QueryChain _chain;

  QueryRunner(this._chain);

  /// Runs the query chain
  dynamic run() {
    // Get all the random stuff needed
    Model model = _chain.model;
    var dataSource = model.dataSource;
    var adapter = adapters(dataSource);

    // Return the result of the query adapter run
    return adapter.execute(_chain);
  }
}
