import 'dart:async';
import 'package:postgresql/postgresql.dart' as psql;
import '../sql_executor.dart';
import '../../../entities/entity_builder.dart';

/// Implementation of the postgres query executor
class PostgresQueryExecutor extends SqlExecutor {
  dynamic conn;
  int _tokenCount = 0;

  PostgresQueryExecutor(adapter, chain) : super(adapter, chain) {
    // Setup the values and entities sets
    values = new List();
    entities = new List();
  }

  // Return the placeholder that postgres lib uses
  getPlaceholder(field) => '@${_tokenCount++}';

  // Execute some sql
  executeSql(sql) async {
    conn = await psql.connect(adapter.uri);

    if (isInsert) return _execInsert(sql);
    else if (isModify) return _execModify(sql);
    else return await conn.query(sql, values);
  }

  // Execute a modify query
  _execModify(sql) async {
    return isFromEntity
        ? await conn.executeMulti(sql, values)
        : await conn.execute(sql, values);
  }

  // Execute insertion
  _execInsert(sql) async {
    var result = await conn.queryMulti(sql, values);

    var res = [];
    var list = await result.toList();
    for (int i = 0; i < list.length; i++) {
      var id = EntityBuilder.getValue(list[i], key);

      // Set the id on the input entities if that is required
      if (isFromEntity) EntityBuilder.setValue(entities[i], key, id);

      res.add(id);
    }

    return new Future.value(res);
  }

  // Executes a query that will return a single Future
  Future execSingleResult() async {
    var results = await executeSql(buildQuery());

    if (isModify) {
      conn.close();

      return results;
    } else {
      List rows = await results
          .map((row) => EntityBuilder.unwrap(chain.entity, row.toMap()))
          .where((user) => filter != null ? filter(user) : true)
          .toList();

      conn.close();

      return new Future.value(!rows.isEmpty ? rows.first : null);
    }
  }

  // Executes a query that will return a Stream, hence the generator
  Stream execMultiResults() async* {
    var results = await executeSql(buildQuery());

    // Use this to attach the connection close
    var ctrl = new StreamController();
    var done = ctrl.addStream(results);

    // When done close the controller and the connection
    done.then((_) {
      ctrl.close();
      conn.close();
    });

    yield* ctrl.stream
        .map((row) => EntityBuilder.unwrap(chain.entity, row.toMap()))
        .where((user) => filter != null ? filter(user) : true);
  }

  List mapInsertCmd(token) {
    var result = super.mapInsertCmd(token);
    result.add('returning $key'); // Add the primary key mapping
    return result;
  }
}