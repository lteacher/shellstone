library shellstone;

import 'metadata/adapters_test.dart' as adapters;
import 'metadata/annotations_test.dart' as annotations;
import 'metadata/metadata_test.dart' as metadata;
import 'datalayer/querylang_test.dart' as queries;
import 'entities/entities_test.dart' as entities;
import 'notification/events_test.dart' as events;
// import 'models/models_test.dart' as models;
import 'datalayer/schema_test.dart' as schema;
import 'datalayer/mysql_adapter_test.dart' as mysql;
import 'datalayer/postgres_adapter_test.dart' as postgres;

main() {
  adapters.main();
  annotations.main();
  metadata.main();
  queries.main();
  entities.main();
  events.main();
  // // models.main();
  schema.main();
  mysql.main();
  postgres.main();
}
