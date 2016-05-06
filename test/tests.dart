library shellstone;

import 'metadata/adapters_test.dart' as adapters;
import 'metadata/annotations_test.dart' as annotations;
import 'metadata/metadata_test.dart' as metadata;
import 'datalayer/querylang_test.dart' as queries;
import 'entities/entities_test.dart' as entities;
import 'notification/events_test.dart' as events;
import 'datalayer/mysql_adapter_test.dart' as mysql;

main() {
  adapters.main();
  annotations.main();
  metadata.main();
  queries.main();
  entities.main();
  events.main();
  mysql.main();
}
