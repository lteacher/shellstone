import 'dart:async';
import 'package:postgresql/postgresql.dart' as psql;
import '../sql_executor.dart';
import '../../../metadata/metadata.dart';
import '../../../entities/entity_builder.dart';

/// Implementation of the postgres query executor
class PostgresQueryExecutor extends SqlExecutor {
  dynamic conn;

  PostgresQueryExecutor(adapter, chain) : super(adapter, chain) {
    // Setup the values and entities sets
    values = new Map();
    entities = new List();
  }

  // Return the placeholder that postgres lib uses
  getPlaceholder(field) => '@$field';

  // Execute some sql
  executeSql(sql) async {
    conn = await psql.connect(adapter.uri);

    var result = isModify && !isInsert
        ? await conn.execute(sql, values)
        : await conn.query(sql, values);

    if (isInsert) {
      var res = [];
      var list = await result.toList();
      for (int i=0; i< list.length; i++) {
        var id = EntityBuilder.getValue(list[i], key);
        EntityBuilder.setValue(entities[i], key, id);
        res.add(id);
      }

      return new Future.value(res);
    } else {
      return result;
    }
  }

  // Executes a query that will return a single Future
  Future execSingleResult() async {
    var results = await executeSql(buildQuery());

    if (isModify) {
      conn.close();

      return results;
    } else {
      List rows = await results
          .map((row) => Metadata.unwrap(chain.entity, row.toMap()))
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
    var done =  ctrl.addStream(results);

    // When done close the controller and the connection
    done.then((_) {
      ctrl.close();
      conn.close();
    });

    yield* ctrl.stream
        .map((row) => Metadata.unwrap(chain.entity, row.toMap()))
        .where((user) => filter != null ? filter(user) : true);
  }

  List mapInsertCmd(token) {
    var result = super.mapInsertCmd(token);
    result.add('returning $key'); // Add the primary key mapping
    return result;
  }

  // get actionCmd {
  //   switch (chain.action) {
  //     case 'update':
  //     case 'updateAll':
  //       return 'update ${chain.resource} set';
  //     default:
  //       return super.actionCmd;
  //   }
  // }
}
