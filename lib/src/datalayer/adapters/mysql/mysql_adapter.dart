import 'dart:async';
import 'package:sqljocky/sqljocky.dart' as mysql;
import 'mysql_query_executor.dart';
import 'mysql_builder.dart';
import '../sql_adapter.dart';
import '../../querylang.dart';

class MysqlAdapter extends SqlAdapter {
  mysql.ConnectionPool conn;

  MysqlAdapter() {
    user = 'root';
    password = 'root';
    host = 'localhost';
    port = 3306;
    db = 'test';
  }

  // Name getter
  get name => 'mysql';

  /// No special config is required
  Future configure() async {}

  // Setup the connection pool
  Future connect() {
    pool ??= new mysql.ConnectionPool(
        host: host,
        port: port,
        user: user,
        password: password,
        db: db,
        max: 5);
  }

  /// Close any connections
  Future disconnect() async => await pool.closeConnectionsWhenNotInUse();

  // Build any tables etc
  Future build() async {
    var builder = new MysqlBuilder(this);
    var statements = builder.getStatements();
    return Future.forEach(statements, (sql) => executeSql(sql));
  }

  /// Returns an sqljocky connection
  Future<mysql.RetainedConnection> get driver async =>
      await pool.getConnection();

  // The query execution method
  execute(chain) => new MysqlQueryExecutor(this, chain).execute();

  // Execute some sql
  executeSql(String sql) => new MysqlQueryExecutor(this).executeSql(sql);
}
