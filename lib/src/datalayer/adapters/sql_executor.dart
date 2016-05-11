import 'dart:async';
import '../database_adapter.dart';
import '../querylang.dart';
import '../schema/schema.dart';
import '../../entities/entity_builder.dart';
import '../../entities/entity_definition.dart';

/// Provides some helper functionality that might be useful for sql adapters
abstract class SqlExecutor {
  DatabaseAdapter adapter;
  QueryChain chain;
  EntityDefinition def;
  Schema schema;
  dynamic filter;
  dynamic values;
  dynamic entities;

  SqlExecutor(this.adapter, this.chain) {
    def = EntityBuilder.getDefinition(chain.entity);
    schema = Schema.get(chain.entity);
  }

  /// Execute the query
  execute() => isMulti ? execMultiResults() : execSingleResult();

  /// Execute an SQL query string
  executeSql(String sql);

  /// Gets the relevant sql operator for the given operator e.g. eq -> =
  getOperator(String op) {
    switch (op) {
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
        return '';
    }
  }

  /// Gets a join term for a given operator, e.g. where || and -> 'and'
  getJoinTerm(String op) {
    switch (op) {
      case 'where':
      case 'and':
        return 'and';
      case 'or':
        return op;
      default:
        return '';
    }
  }

  /// Get action command from the [QueryAction]
  get actionCmd {
    switch (chain.action) {
      case 'get':
      case 'find':
      case 'findAll':
        return 'select * from ${chain.resource}';
      case 'insert':
      case 'insertAll':
        return 'insert into ${chain.resource}';
      case 'update':
      case 'updateAll':
        return 'update ${chain.resource} set';
      case 'remove':
      case 'removeAll':
        return 'delete from ${chain.resource}';
    }
  }

  // Insertion placeholder, like `?` or `@name`
  getPlaceholder(field);

  // Builds the sql query from the chain
  buildQuery() {
    values.clear();
    List commands = [actionCmd];

    for (var i = 0, j = 1; i < chain.length; i++, j++) {
      QueryToken token = chain[i];

      if (token.operator == 'filter') {
        // Set the filter
        filter = token.args.first;
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
    if (!isMulti && !isModify && filter == null && !commands.contains('limit'))
      commands.add('limit 1');
  }

  // Map an update command
  mapUpdateCmd(token) {
    entities = token.args;
    var fields = fieldNames.where((f) => f != key);

    token.args.map(EntityBuilder.wrap).forEach((Map map) {
      // Capture the key value
      var keyValue = map[key];

      if (values is List) {
        // ditch the key
        _stripPrimaryKey(map);

        // Add the values as a straight list of values
        var list = map.values.toList();
        list.add(keyValue); // Add the keyvalue back in as an append
        values.add(list);
      } else if (values is Map) {
        // Add the entire map as is
        values.addAll(map);
      }
    });

    var buffer = fields.fold(new StringBuffer(), (StringBuffer prev, field) {
      if (!prev.isEmpty) prev.write(', ');

      prev.write('$field = ${getPlaceholder(field)}');
      return prev;
    });

    // Add a where clause in for the id TODO: Remove when insert / insertFrom
    buffer.write(' where $key = ${getPlaceholder(key)}');

    return buffer.toString();
  }

  // Maps the insert command
  List mapInsertCmd(token) {
    var fields = fieldNames.where((f) => f != key);
    var result = []..add('(${fields.join(',')})');
    entities = token.args;

    token.args.map(EntityBuilder.wrap).forEach((Map map) {
      // Strip the id out?
      _stripPrimaryKey(map);

      if (values is List) {
        // Add the values as a straight list of values
        values.add(map.values.toList());
      } else if (values is Map) {
        // Add the entire map as is
        values = new Map.from(map);
      }
    });

    // Get the fields out, skip the primary key TODO: only for auto incr?
    var placeholders = fields.map(getPlaceholder);

    // Add the placeholder list
    result.add('values (${placeholders.join(', ')})');

    return result;
  }

  // Maps an identifier
  mapIdentifierCmd(token) {
    if (!isModify) {
      if (values is List) values.add(token.args.first);
      if (values is Map) values[key] = token.args.first;
    } else {
      token.args.forEach((entity) {
        if (values is List) values.add([EntityBuilder.getValue(entity, key)]);
        if (values is Map) values[key] = EntityBuilder.getValue(entity, key);
      });
    }

    return 'where $key = ${getPlaceholder(key)}';
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
    var fields = token.args.map(_getColumnName);

    // Add values
    if (values is List) values.addAll(next.args);
    if (values is Map) values.addAll(new Map.fromIterables(fields, next.args));

    // Tokens need to be joined together
    var buffer = fields.fold(new StringBuffer(), (StringBuffer prev, field) {
      if (!prev.isEmpty) prev.write(' $joiner ');

      prev.write('$field $op ${getPlaceholder(field)}');
      return prev;
    });

    return buffer.toString();
  }

  execSingleResult();
  execMultiResults();

  // Strip out the primary key, used on insert
  _stripPrimaryKey(Map map) {
    var field = schema.primaryKey;

    // Remove key by field name
    var result = map.remove(field.name);

    // Didnt remove anything then must be mapped to column so remove that
    if (result == null) map.remove(field.column);
  }

  get fieldNames => def.fieldNames.map(_getColumnName);
  get key => schema.primaryKey.name;
  get isMulti => chain.action == 'findAll';
  get isInsert => chain.action == 'insert' || chain.action == 'insertAll';
  get isModify =>
      isInsert ||
      chain.action == 'update' ||
      chain.action == 'updateAll' ||
      chain.action == 'remove' ||
      chain.action == 'removeAll';

  // Gets a column name else returns the given
  _getColumnName(name) {
    var field = schema.getField(name);
    return field != null ? field.column : name;
  }
}
