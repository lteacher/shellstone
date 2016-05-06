import 'dart:async';
import '../database_adapter.dart';
import '../schema.dart';

// Contains a base sql database adapter which can be extended
abstract class SqlAdapter extends DatabaseAdapter {
  // An implementation of build
  Future build() {
    // Get all the schemas of this DB type
    List schemas =
        Schema.getAll().where((schema) => schema.source == this.name);


  }

  // Abstract execute method to be implemented
  Future executeSql(String sql);
}
