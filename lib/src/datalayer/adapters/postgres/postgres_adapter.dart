import 'dart:async';
import 'package:postgresql/postgresql.dart' as psql;
import 'package:postgresql/pool.dart' as psql;
import 'postgres_query_executor.dart';
import 'postgres_builder.dart';
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
  get name => 'postgres';

  /// Setup the connection pool. This occurs only if [conn] is not set
  /// That gives an adapter listener a chance to create it instead
  Future configure() async {
    uri = 'postgres://$user:$password@$host:$port/$db';
  }

  // Setup the connection.. Pool is just not up to scratch. Consider fixing it
  Future connect() {
    if (pool == null) {
      pool = new psql.Pool(uri,minConnections: 2, maxConnections: 5);

      // Return the completers future instead
      return pool.start();
    }
  }

  /// Close any connections
  Future disconnect() {
    return pool.stop();
  }

  // Build any tables etc
  Future build() async {
    var builder = new PostgresBuilder(this);
    var statements = builder.getStatements();
    return Future.forEach(statements, (sql) => executeSql(sql,true));
  }

  /// Returns an sqljocky connection
  Future<psql.Connection> get driver async =>
      await pool.connect();

  // The query execution method
  execute(chain) => new PostgresQueryExecutor(this, chain).execute();

  // Execute some sql
  executeSql(String sql,[bool release]) => new PostgresQueryExecutor(this).executeSql(sql,release);
}
