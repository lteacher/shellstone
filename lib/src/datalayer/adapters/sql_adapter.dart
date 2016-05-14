import 'dart:async';
import '../database_adapter.dart';
import '../schema/schema.dart';

// Contains a base sql database adapter which can be extended
abstract class SqlAdapter extends DatabaseAdapter {
  // Abstract execute method to be implemented
  Future executeSql(String sql);
}
