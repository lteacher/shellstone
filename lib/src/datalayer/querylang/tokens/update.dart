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

class UpdateQuery extends QueryDelegator {
  UpdateQuery(chain,values) : super(chain) {
    new Update(chain,values); // Will add itself on creation.
  }
}
