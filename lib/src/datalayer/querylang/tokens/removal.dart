import 'query.dart';
import 'runnable.dart';
import '../query_token.dart';

class Removal extends QueryToken
    implements SingleResultRunnable, MultipleResultRunnable {
  Removal(chain,values,[result]) : super(chain) {
    init('remove', values, result);
  }

  run() => runChain();
}

class RemovalQuery extends QueryDelegator {
  RemovalQuery(chain,values) : super(chain) {
    new Removal(chain, values);
  }
}
