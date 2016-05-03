import 'runnable.dart';
import '../query_token.dart';

class Update extends QueryToken
    implements SingleResultRunnable, MultipleResultRunnable {
  Update(chain,values) : super(chain) {
    init('update', values, null);
  }

  run() => runChain();
}
