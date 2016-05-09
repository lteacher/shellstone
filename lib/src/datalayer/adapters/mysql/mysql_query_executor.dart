import 'dart:async';
import '../sql_executor.dart';
import '../../../metadata/metadata.dart';
import '../../../entities/entity_builder.dart';

/// A class to encapsulate the query execution logic
///
/// There is some bother in duplication of logic because of the dynamic
/// return of either a stream or future. There is probably a nicer way
/// to get around that but for now... got to go with what works
class MysqlQueryExecutor extends SqlExecutor {
  MysqlQueryExecutor(adapter, chain) : super(adapter, chain) {
    values = new List();
    entities = new List();
  }

  // Return the insertion placeholder, which is just ?
  getPlaceholder(field) => '?';

  // Executes a query
  Future executeSql(String sql) async {
    var q = await adapter.pool.prepare(sql);

    // If modify unfortunately a List<Results> is returned... so a List<Stream>
    // which literally just has an id per stream so I cant accept that. Need to
    // squash them into a single list of ids. Frankly the ids should be
    // injected back into the entities
    if (isModify) {
      var results = [];
      List res = await q.executeMulti(values);

      if (isInsert) {
        for (int i = 0; i < res.length; i++) {
          var id = res[i].insertId;

          // Add the result back in
          results.add(id);
          EntityBuilder.setValue(entities[i], key, id);
        }
      } else {
        // Return the sum of the affected rows
        return res.fold(0, (prev, curr) => curr.affectedRows + prev);
      }

      await q.close();
      return new Future.value(results);
    } else {
      var results = await q.execute(values);

      await q.close();
      return results;
    }
  }

  // Executes a query that will return a single Future
  Future execSingleResult() async {
    var results = await executeSql(buildQuery());

    if (isModify) {
      // Somehow its a stream of streams?
      return results;
    } else {
      var fields = results.fields.map((f) => f.name);

      // Get the rows to a list and map it as otherwise its
      // just not possible to know if it is empty to take the `first`
      List rows = await results
          .map((row) => new Map.fromIterables(fields, row))
          .map((row) => Metadata.unwrap(chain.entity, row))
          .where((user) => filter != null ? filter(user) : true)
          .toList();

      return new Future.value(!rows.isEmpty ? rows.first : null);
    }
  }

  // Executes a query that will return a Stream, hence the generator
  Stream execMultiResults() async* {
    var results = await executeSql(buildQuery());

    var fields = results.fields.map((f) => f.name);

    yield* results
        .map((row) => new Map.fromIterables(fields, row))
        .map((row) => Metadata.unwrap(chain.entity, row))
        .where((user) => filter != null ? filter(user) : true);
  }
}
