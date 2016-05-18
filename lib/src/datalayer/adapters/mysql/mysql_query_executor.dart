import 'dart:async';
import '../sql_executor.dart';
import '../../../entities/entity_builder.dart';

/// A class to encapsulate the query execution logic
///
/// There is some bother in duplication of logic because of the dynamic
/// return of either a stream or future. There is probably a nicer way
/// to get around that but for now... got to go with what works
class MysqlQueryExecutor extends SqlExecutor {
  MysqlQueryExecutor(adapter, [chain]) : super(adapter, chain) {
    values = new List();
    entities = new List();
  }

  // Return the insertion placeholder, which is just ?
  getPlaceholder(field) => '?';

  // Executes a query
  Future executeSql(String sql, [bool release]) async {
    var query = await adapter.pool.prepare(sql);

    var results;

    if (isInsert)
      results = _execInsert(query);
    else if (isModify)
      results = _execModify(query);
    else
      results = await query.execute(values);

    await query.close();

    return results;
  }

  // Called for all non insertions
  _execModify(query) async {
    List result = isFromEntity
        ? await query.executeMulti(values)
        : await query.executeMulti([values]);

    return result.fold(0, (prev, curr) => curr.affectedRows + prev);
  }

  // Specific insert function
  _execInsert(query) async {
    var results = [];
    List res = await query.executeMulti(values);

    for (int i = 0; i < res.length; i++) {
      var id = res[i].insertId;

      // Set the id on the input entities if that is required
      if (isFromEntity) EntityBuilder.setValue(entities[i], key, id);

      // Add the result back in
      results.add(id);
    }

    return results;
  }

  // Executes a query that will return a single Future
  Future execSingleResult() async {
    var results = await executeSql(buildQuery());

    if (isModify) {
      return results;
    } else {
      List rows = await _mapResults(results);

      return new Future.value(!rows.isEmpty ? rows.first : null);
    }
  }

  Future _mapResults(results) async {
    var fields = results.fields.map((f) => f.name);

    // Return the mapped results list
    return await results
        .map((row) => new Map.fromIterables(fields, row))
        .map((row) => EntityBuilder.unwrap(chain.entity, row))
        .where((user) => filter != null ? filter(user) : true)
        .toList();
  }

  // Executes a query that will return a list of results
  Future<List<dynamic>> execMultiResults() async =>
      _mapResults(await executeSql(buildQuery()));
}
