import 'sql_adapter.dart';
import '../schema/schema.dart';
import '../schema/schema_field.dart';

/// An abstract class to help with build functionality for sql based adapters
abstract class SqlBuilder {
  SqlAdapter _adapter;
  Iterable _schemas;

  // Constructed with an adapter
  SqlBuilder(this._adapter) {
    _schemas = Schema.getAll().where((s) => s.source == _adapter.name);
  }

  /// Returns a list of the statements to create the tables for each schema
  List<String> getStatements() {
    // Add the table creation statements
    return _schemas.fold(new List(), (list, schema) {
      list.addAll(getTableStatements(schema));
      if (schema.indexes.isNotEmpty) list.addAll(getIndexStatements(schema));
      return list;
    });
  }

  /// Get the statement to execute
  List<String> getTableStatements(Schema schema) {
    List results = [];
    StringBuffer buffer = new StringBuffer();

    // Add drop statement if makes sense
    if (schema.migration == 'drop')
      results.add('drop table if exists ${schema.resource};');

    // Table create statement
    buffer.write('create table if not exists ${schema.resource}');

    // Buffer the field lines
    var fields = schema.allFields.values.fold(new List(), (list,field) {
      list.add(getFieldLine(field));
      return list;
    }).join(',');

    // Add the fields
    buffer.write('($fields, ${getPrimaryKey(schema)});');

    results.add(buffer.toString());
    return results;
  }

  /// Should return a field line such as
  String getFieldLine(SchemaField field) {
    return '${field.column} ${getType(field)}';
  }

  // Convert the type
  String getType(SchemaField field) {
    List<String> result = [];
    var length = field.length > 0 ? field.length : 255;

    switch (field.type) {
      case 'string':
        result.add('varchar(${length})');
        break;
      case 'integer':
        result.add('int');
        break;
      case 'boolean':
        result.add('tinyint(1)');
        break;
      default:
        result.add(field.type);
    }

    // Add constraints
    if (field.unique) result.add('unique not null');
    if (field.autoIncr) result.add('auto_increment');

    return result.join(' ');
  }

  // Get the statements to add all the indexes
  List<String> getIndexStatements(Schema schema) {
    return schema.indexes.values.fold(new List(),(list,field) {
      list.add('alter table ${schema.resource} add index(${field.column})');
      return list;
    });
  }

  String getPrimaryKey(Schema schema) => 'primary key (${schema.primaryKey.column})';
}
