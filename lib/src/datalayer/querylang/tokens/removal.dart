import 'filter.dart';
import 'query.dart';
import 'runnable.dart';
import 'modifier.dart';
import '../query_token.dart';

class Removal extends QueryToken
    implements SingleResultRunnable, MultipleResultRunnable {
  Removal(chain,values,[result]) : super(chain) {
    init('remove', values, result);
  }

  run() => runChain();
}

class RemovalQuery extends Removal implements SingleResultQuery {
  RemovalQuery(chain,values) : super(chain,values, new Filter(chain));

  where(fields) => init('where', fields, new Filter(chain));
  filter(fn) => init('filter', fn, new Modifier(chain));
}
