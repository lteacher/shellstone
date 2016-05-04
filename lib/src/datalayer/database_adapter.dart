import 'dart:async';
import 'querylang.dart';

/// An adapter which sets up database connections and handles queries
///
/// Each of the methods will be called in order:
/// - [DatabaseAdapter.configure]
/// - [DatabaseAdapter.connect]
/// - [DatabaseAdapter.build]
///
/// When queries are executed the [DatabaseAdapter.execute] method will be called
abstract class DatabaseAdapter {
  Map<String,dynamic> parms = new Map();
  dynamic pool;
  dynamic conn;
  String user;
  String password;
  String host;
  int port;
  String db;

  DatabaseAdapter();

  /// Getter for the adapter name, e.g. `mysql`
  String get name;

  /// Return the most relevant thing to an api from the underlying package.
  /// for example the mysql package might return a connection from sqljocky
  Future get driver;

  /// Configure some things before connect
  Future configure();

  /// Connect to the database
  Future connect();

  /// Build any relevant tables, uses the shellstone metadata
  Future build();

  // Disconnect the database
  Future disconnect();

  /// Execute a query chain
  dynamic execute(QueryChain chain);
}
