import 'dart:async';
import 'package:postgresql/postgresql.dart' as psql;
import 'package:postgresql/pool.dart' as psql;
import 'postgres_query_executor.dart';
import '../sql_adapter.dart';
import '../../querylang.dart';

class PostgresAdapter extends SqlAdapter {
  psql.Pool conn;
  var uri;

  PostgresAdapter() {
    user = 'postgres';
    password = 'root';
    host = 'localhost';
    port = 5432;
    db = 'test';
  }

  // Name getter
  get name => 'mysql';

  /// Setup the connection pool. This occurs only if [conn] is not set
  /// That gives an adapter listener a chance to create it instead
  Future configure() async {
    uri = 'postgres://$user:$password@$host:$port/$db';

    if (pool == null) {
      // pool = new psql.Pool(uri,minConnections: 2, maxConnections: 5);

      // pool.messages.listen(print);

      // Somehow this doesn't execute till later its very odd??
      // return pool.start();
    }
  }

  /// Setup the connection, nothing to do here
  Future connect() {}

  /// Close any connections
  Future disconnect() {}

  // TODO: For later release
  Future build() {}

  /// Returns an sqljocky connection
  Future<psql.Connection> get driver async =>
      await pool.connect();

  // The query execution method
  execute(chain) => new PostgresQueryExecutor(this, chain).execute();

  // Execute some sql
  executeSql(String sql) => new PostgresQueryExecutor(this, new QueryChain()).executeSql(sql);
}
