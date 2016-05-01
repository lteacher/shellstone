import 'runnable.dart';
import '../query_token.dart';

class Insertion extends QueryToken
    implements SingleResultRunnable, MultipleResultRunnable {
  Insertion(chain,values) : super(chain) {
    init('insert', values, null);
  }

  run() => runChain();
}
