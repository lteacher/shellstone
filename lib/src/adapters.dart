part of shellstone;

/// Used by a DB adapter to map a Shellstone query for mapping to the underlying query
///
/// The [QueryAdapter] is created with a given action, such as `find`
/// after this the [QueryAdapter.mapToken] method is called repeatedly
/// for each chainable in the [QueryChain].
abstract class QueryAdapter implements Runnable {
  dynamic db; // Will be injectd by the framework

  final String action;
  final String resource;

  QueryAdapter(this.action, this.resource);

  /// The abstract method [mapToken] is called for every [Callable] in
  /// the [QueryChain]. Use the token to map internally a query that will be executed
  mapToken(QueryToken token);
}

/// The DatabaseAdapter is constructed once only. It provides a means to maintain
/// some connection state since the [QueryAdapter] only lives as long as the query
/// so each new query will have access to the database adapter via [Shellstone.adapters]
abstract class DatabaseAdapter {
  Map<String,dynamic> parms = new Map();
  dynamic conn;
  String user;
  String password;
  String host;
  int port;

  DatabaseAdapter();

  /// Connect to the database
  Future connect();

  /// Build any relevant tables, uses the shellstone metadata
  Future build();

  // Disconnect the database
  Future disconnect();

  /// Called to get a [QueryAdapter] instance for a database implementation.
  ///
  /// Because QueryAdapters are throwaway after execution.
  QueryAdapter getQueryAdapter(String action, String resource);
}

// A mockup adapter
class MockDatabaseAdapter extends DatabaseAdapter {
  MockDatabaseAdapter() {
    user = 'fakeUser';
    password = '123413';
  }

  configure() {}
  connect() {}
  build() {}
  disconnect() {}

  // Returns nothing
  getQueryAdapter(action,resource) {}
}
