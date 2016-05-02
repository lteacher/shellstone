import 'runnable.dart';
import '../query_token.dart';

class Removal extends QueryToken
    implements SingleResultRunnable, MultipleResultRunnable {
  Removal(chain,values) : super(chain) {
    init('remove', values, null);
  }

  run() => runChain();
}
