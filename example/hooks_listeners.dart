import 'package:shellstone/shellstone.dart';

@Hook(Adapter.configure)
setCredentials(event) {
  var adapter = event.data;

  adapter.user = 'root';
  adapter.password = 'root';
  adapter.host = '127.0.0.1';
  adapter.db = 'test';
}

@Listen(Adapter.configure)
doSomethingSpecial(event) {
  var adapter = event.data;

  adapter.user = 'root';
  adapter.password = 'root';
  adapter.host = '127.0.0.1';
  adapter.db = 'test';
}

main() async {
  await strapIn();
}
