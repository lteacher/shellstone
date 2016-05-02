library shellstone;

import 'adapters_test.dart' as adapters;
import 'annotations_test.dart' as annotations;
import 'metadata_test.dart' as metadata;
import 'querylang_test.dart' as queries;
import 'utils_test.dart' as utils;
import 'events_test.dart' as events;
import 'mysql_adapter_test.dart' as mysql;

main() {
  adapters.main();
  annotations.main();
  metadata.main();
  queries.main();
  utils.main();
  events.main();
  mysql.main();
}
