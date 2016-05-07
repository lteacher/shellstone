import 'dart:async';
import 'package:sqljocky/sqljocky.dart' as mysql;
import '../sql_executor.dart';
import '../../querylang.dart';
import '../../../entities/entity_builder.dart';
import '../../../metadata/metadata.dart';

/// A class to encapsulate the query execution logic
///
/// There is some bother in duplication of logic because of the dynamic
/// return of either a stream or future. There is probably a nicer way
/// to get around that but for now... got to go with what works
class MysqlQueryExecutor extends SqlExecutor {
  List _values = [];
  List _entities;
  dynamic _filter;

  MysqlQueryExecutor(adapter, chain) : super(adapter, chain);

  // Executes a query (currently only findAll is multiple results)
  execute() => isMulti ? _multiExec() : _singleExec();

  // Execute some sql
  executeSql(sql) => _execQuery(sql);

  // Builds the sql query from the chain
  buildQuery() {
    _values.clear();
    List commands = [actionCmd];

    for (var i = 0, j = 1; i < chain.length; i++, j++) {
      QueryToken token = chain[i];

      if (token.operator == 'filter') {
        // Set the filter
        _filter = token.args.first;
      } else if (token is Query || token is Selector) {
        QueryToken next = chain[j];

        // Add the mapped [where,and,or] operator
        commands.add(token.operator);

        // Add the command for a selection
        commands.add(mapSelectorCmd(token, next));

        // Increment with extra since we processed 2 tokens
        i++;
        j++;
      } else if (token is Modifier) {
        commands.add(mapModifierCmd(token));
      } else if (token is Identifier || token is Removal) {
        commands.add(mapIdentifierCmd(token));
      } else if (token is Insertion) {
        commands.addAll(mapInsertCmd(token));
      } else if (token is Update) {
        commands.add(mapUpdateCmd(token));
      }
    }

    // Add limit if req
    _addLimit(commands);

    return commands.join(' ');
  }

  // If a limit hasnt been added, which it shouldnt have for a single
  // result, add it to the end (TODO, dont allow limit in single queries)
  _addLimit(List commands) {
    if (!isMulti && !isModify && _filter == null && !commands.contains('limit'))
      commands.add('limit 1');
  }

  // Map an update command
  mapUpdateCmd(token) {
    _entities = token.args;

    token.args.map(Metadata.wrap).forEach((Map map) {
      // Add the values as a straight list of values
      _values.add(map.values.toList());
    });

    var buffer = fieldNames.fold(new StringBuffer(), (StringBuffer prev, field) {
      if (!prev.isEmpty) prev.write(', ');

      prev.write('$field = ?');
      return prev;
    });

    return buffer.toString();
  }

  // Maps the insert command
  List mapInsertCmd(token) {
    var result = []..add('(${fieldNames.join(',')})');
    _entities = token.args;

    token.args.map(Metadata.wrap).forEach((Map map) {
      // Add the values as a straight list of values
      _values.add(map.values.toList());
    });

    // Add command for placeholders
    result.add(
        'values (${new List.generate(fieldNames.length, (i) => '?').join(', ')})');

    return result;
  }

  // Maps an identifier
  mapIdentifierCmd(token) {
    var key = schema.primaryKey.name;

    if (!isModify)
      _values.add(token.args.first);
    else {
      token.args.forEach((entity) {
        _values.add([EntityBuilder.getValue(entity, key)]);
      });
    }

    return 'where $key = ?';
  }

  // Maps some kind of modifier
  mapModifierCmd(token) {
    if (token.operator == 'limit') return 'limit ${token.args[0]}';
  }

  // Maps a command for some kind of selector
  mapSelectorCmd(token, next) {
    // Get the join, such as and, or
    var joiner = getJoinTerm(token.operator);
    var op = getOperator(next.operator);

    // Add right side as values for later query execute
    _values.addAll(next.args);

    // Tokens need to be joined together
    var buffer =
        token.args.fold(new StringBuffer(), (StringBuffer prev, field) {
      if (!prev.isEmpty) prev.write(' $joiner ');

      prev.write('$field $op ?');
      return prev;
    });

    return buffer.toString();
  }

  // Executes a query that will return a single Future
  Future _singleExec() async {
    var results = await _execQuery(buildQuery());

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
          .where((user) => _filter != null ? _filter(user) : true)
          .toList();

      return new Future.value(!rows.isEmpty ? rows.first : null);
    }
  }

  // Executes a query that will return a Stream, hence the generator
  Stream _multiExec() async* {
    var results = await _execQuery(buildQuery());

    var fields = results.fields.map((f) => f.name);

    yield* results
        .map((row) => new Map.fromIterables(fields, row))
        .map((row) => Metadata.unwrap(chain.entity, row))
        .where((user) => _filter != null ? _filter(user) : true);
  }

  // Executes a query
  Future _execQuery(String sql) async {
    var q = await adapter.pool.prepare(sql);

    // If modify unfortunately a List<Results> is returned... so a List<Stream>
    // which literally just has an id per stream so I cant accept that. Need to
    // squash them into a single list of ids. Frankly the ids should be
    // injected back into the entities
    if (isModify) {
      var results = [];
      List res = await q.executeMulti(_values);

      if (isInsert) {
        for (int i = 0; i < res.length; i++) {
          var id = res[i].insertId;

          // Add the result back in
          results.add(id);
          _entities[i].id = id;
        }
      } else {
        // Return the sum of the affected rows
        return res.fold(0, (prev, curr) => curr.affectedRows + prev);
      }

      await q.close();
      return new Future.value(results);
    } else {
      var results = await q.execute(_values);

      await q.close();
      return results;
    }
  }
}
