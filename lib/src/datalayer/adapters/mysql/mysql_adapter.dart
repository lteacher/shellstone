import 'dart:async';
import 'package:sqljocky/sqljocky.dart' as mysql;
import 'mysql_query_executor.dart';
import '../../database_adapter.dart';

class MysqlAdapter extends DatabaseAdapter {
  mysql.ConnectionPool conn;

  MysqlAdapter() {
    user = 'root';
    password = 'root';
    host = 'localhost';
    port = 3306;
    db = 'shellstone';
  }

  // Name getter
  get name => 'mysql';

  /// Setup the connection pool. This occurs only if [conn] is not set
  /// That gives an adapter listener a chance to create it instead
  Future configure() async {
    if (pool == null) {
      pool = new mysql.ConnectionPool(
          host: host,
          port: port,
          user: user,
          password: password,
          db: db,
          max: 5);
    }
  }

  /// Setup the connection, nothing to do here
  Future connect() {}

  /// Close any connections
  Future disconnect() async => await pool.closeConnectionsWhenNotInUse();

  // TODO: For later release
  Future build() {}

  /// Returns an sqljocky connection
  Future<mysql.RetainedConnection> get driver async => await pool.getConnection();

  // The query execution method
  execute(chain) => new MysqlQueryExecutor(this,chain).execute();
}
