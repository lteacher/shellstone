part of shellstone;

/// Defines the type that will be used to match the annotated handlers
// typedef DBEventHandler<T extends DatabaseAdapter, QueryAdapter>(T adapter);
typedef DBEventHandler(adapter);

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
  DatabaseAdapter() {}
  DatabaseAdapter.configure();

  /// Called to get a [QueryAdapter] instance for a database implementation.
  ///
  /// Because QueryAdapters are throwaway after execution.
  QueryAdapter getQueryAdapter(String action, String resource);
}

/// TODO: A database adapter for mongodb
class MongoDatabaseAdapter extends DatabaseAdapter {
  MongoDatabaseAdapter.configure() {}

  getQueryAdapter(action, resource) => new MongoQueryAdapter(action, resource);
}

// <=======================================================================
// For now I am going to jam some adapters into this and see how it fits
// <=======================================================================
class MongoQueryAdapter extends QueryAdapter {
  MongoQueryAdapter(action, resource) : super(action, resource);

  mapToken(QueryToken token) {}

  run() {}
}

/// TODO: A database adapter for mysql
class MysqlDatabaseAdapter extends DatabaseAdapter {
  ConnectionPool pool;

  MysqlDatabaseAdapter.configure() {
    pool = new ConnectionPool(
        host: 'localhost',
        port: 3306,
        user: 'root',
        password: 'root',
        db: 'shellstone',
        max: 5);
  }

  getQueryAdapter(action, resource) => new MysqlQueryAdapter(action, resource);
}

class MysqlQueryAdapter extends QueryAdapter {
  MysqlQueryAdapter(action, resource) : super(action, resource);

  mapToken(QueryToken token) {
    print(token);
  }

  run() async {
    return db.pool.query('select * from User');
  }
}
