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

  SqlExecutor(this.adapter, this.chain) {
    def = EntityBuilder.getDefinition(chain.entity);
    schema = Schema.get(chain.entity);
  }

  /// Execute the query
  execute();

  /// Execute an SQL query string
  executeSql(String sql);

  /// Gets the field names for the executing entity type
  get fieldNames => def.fieldNames;

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
        return 'update ignore ${chain.resource} set';
      case 'remove':
      case 'removeAll':
        return 'delete from ${chain.resource}';
    }
  }

  get isMulti => chain.action == 'findAll';
  get isInsert => chain.action == 'insert' || chain.action == 'insertAll';
  get isModify =>
      isInsert ||
      chain.action == 'update' ||
      chain.action == 'updateAll' ||
      chain.action == 'remove' ||
      chain.action == 'removeAll';
}
