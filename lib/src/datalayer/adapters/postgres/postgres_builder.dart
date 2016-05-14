import '../sql_builder.dart';

/// Implements the SqlBuilder
class PostgresBuilder extends SqlBuilder {
  PostgresBuilder(adapter) : super(adapter);

  // Convert the type
  String getType(field) {
    List<String> result = [];
    var length = field.length > 0 ? field.length : 255;

    // When auto increment for postgres return serial
    if (field.autoIncr) return 'serial';

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
      case 'double':
        result.add('numeric');
        break;
      default:
        result.add(field.type);
    }

    // Add constraints
    if (field.unique) result.add('unique not null');

    return result.join(' ');
  }
}
