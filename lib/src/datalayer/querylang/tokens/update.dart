import 'filter.dart';
import 'query.dart';
import 'runnable.dart';
import 'modifier.dart';
import '../query_token.dart';

class Update extends QueryToken
    implements SingleResultRunnable, MultipleResultRunnable {
  Update(chain,values,[result]) : super(chain) {
    init('update', values, result);
  }

  run() => runChain();
}

class UpdateQuery extends Update implements SingleResultQuery {
  UpdateQuery(chain,values) : super(chain,values, new Filter(chain));

  where(fields) => init('where', fields, new Filter(chain));
  filter(fn) => init('filter', fn, new Modifier(chain));
}
