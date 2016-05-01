import 'dart:async';
import 'package:sqljocky/sqljocky.dart' as mysql;
import 'mysql_adapter.dart';
import '../../querylang.dart';
import '../../../metadata/metadata.dart';
import '../../../util/entity_wrapper.dart';

/// A class to encapsulate the query execution logic
///
/// There is some bother in duplication of logic because of the dynamic
/// return of either a stream or future. There is probably a nicer way
/// to get around that but for now... got to go with what works
class MysqlQueryExecutor {
  MysqlAdapter _adapter;
  QueryChain<QueryToken> _chain;
  List _values = [];

  MysqlQueryExecutor(this._adapter, this._chain);

  // Executes a query (currently only findAll is multiple results)
  execute() => _isMulti ? _multiExec() : _singleExec();

  // Builds the sql query from the chain
  String _buildSelection() {
    _values.clear();
    List commands = [_actionCommand];

    // Parse the tokens as pairs?
    for (var i = 0, j = 1; i < _chain.length; i++, j++) {
      QueryToken left = _chain[i];
      QueryToken right = (j < _chain.length) ? _chain[j] : null;
      var joiner;
      var op;

      // Left side token is selector
      if (left is Selector || left is Query) {
        // If query push the command `where` in
        if (left is Query) commands.add(left.operator);

        // Get the join, such as and, or
        joiner = _getJoiner(left.operator);
        op = _mapOperator(right.operator);

        // Add right side as values for later query execute
        _values.addAll(right.args);

        // Left side needs to be joined together
        var buffer =
            left.args.fold(new StringBuffer(), (StringBuffer prev, field) {
          if (!prev.isEmpty) prev.write(' $joiner ');

          prev.write('$field $op ?');
          return prev;
        });

        // Add the buffer to the commands
        commands.add(buffer.toString());

        // Add an extra increment for this
        i++;
        j++;
      }

      // Left side token is modifier (e.g. sort, limit)
      if (left is Modifier) {
        if (left.operator == 'limit') commands.add('limit ${left.args[0]}');
      }

      if (left is Insertion) {
        var fields;
        left.args.map((entity) {
          // If we dont know the fields then for the first entity grab them
          // and put them into the query commands
          if (fields == null) {
            fields = _getFields(entity);
            commands.add('(${fields.join(',')})');
          }

          // Return the wrapped entity
          return Metadata.wrap(entity);
        }).forEach((Map map) {
          // Add the values as a straight list of values
          _values.add(map.values.toList());
        });

        // Add command for placeholders
        commands.add(
            'values (${new List.generate(fields.length, (i) => '?').join(', ')})');
      }
    }

    // If a limit hasnt been added, which it shouldnt have for a single
    // result, add it to the end (TODO, dont allow limit in single queries)
    if (!_isMulti && !_isModify && !commands.contains('limit'))
      commands.add('limit 1');

    return commands.join(' ');
  }

  // Executes a query that will return a single Future
  Future _singleExec() async {
    var results = await _execQuery();

    if (_isModify) {
      // Somehow its a stream of streams?
      return results;
    } else {
      var fields = results.fields.map((f) => f.name);

      // Get the rows to a list so we can know if is empty
      // This is very unfortunate, hope to find something better
      List rows = await results.toList();

      return rows.isEmpty
          ? new Future.value() // Return emtpy future
          : new Stream.fromIterable(rows)
              .map((row) => new Map.fromIterables(fields, row))
              .map((row) => Metadata.unwrap('User', row))
              .first;
    }
  }

  // Executes a query that will return a Stream, hence the generator
  Stream _multiExec() async* {
    var results = await _execQuery();

    var fields = results.fields.map((f) => f.name);

    yield* results
        .map((row) => new Map.fromIterables(fields, row))
        .map((row) => Metadata.unwrap('User', row));
  }

  // Executes a query
  Future _execQuery() async {
    var sql = _buildSelection();
    var q = await _adapter.pool.prepare(sql);

    // If modify unfortunately a List<Results> is returned... so a List<Stream>
    // which literally just has an id per stream so I cant accept that. Need to
    // squash them into a single list of ids. Frankly the ids should be
    // injected back into the entities
    if (_isModify) {
      var results = [];
      List res = await q.executeMulti(_values);
      res.forEach((result) {
        results.add(result.insertId);
      });

      await q.close();
      return new Future.value(results);
    } else {
      var results = await q.execute(_values);

      await q.close();
      return results;
    }
  }

  get _isMulti => _chain.action == 'findAll';
  get _isModify =>
      _chain.action == 'insert' ||
      _chain.action == 'insertAll' ||
      _chain.action == 'update' ||
      _chain.action == 'updateAll';

  // Returns the operator for sql
  String _mapOperator(cmd) {
    switch (cmd) {
      case 'eq':
        return '=';
      case 'ne':
        return '<>';
      case 'le':
        return '<=';
      case 'ge':
        return '>=';
      case 'lt':
        return '<';
      case 'gt':
        return '>';
      default:
        '';
    }
  }

  // Returns the keyword mapping for joining selectors together
  String _getJoiner(op) {
    switch (op) {
      case 'where':
      case 'and':
        return 'and';
      case 'or':
        return op;
    }
  }

  get _actionCommand {
    switch (_chain.action) {
      case 'find':
      case 'findAll':
        return 'select * from ${_chain.resource}';
      case 'insert':
      case 'insertAll':
        return 'insert into ${_chain.resource}';
    }
  }

  _getFields(entity) {
    return new EntityWrapper(entity: entity).fields;
  }
}
