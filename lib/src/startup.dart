part of shellstone;

/// The shellstone singleton. When setup is called the lazy initialisation
/// will be triggered
class Shellstone {
  // Metadata singleton
  static final Shellstone _stone = new Shellstone._internal();
  final Map<String,DatabaseAdapter> _adapters = new Map();

  factory Shellstone() => _stone;

  Shellstone._internal() {
    // Scan and build metadata
    new Metadata().scan();

    // Add all the base adapters
    // _adapters['mongo'] = new MongoDatabaseAdapter.configure();
    _adapters['mysql'] = new MysqlDatabaseAdapter.configure();
    // _adapters['rethink'] = RethinkAdapter;
  }

  /// The setup method will launch Shellstone.
  ///
  /// On launch, all Annotations are scanned in. The defaults for the
  /// framework are setup and can be overridden via the provided accessors
  static Shellstone setup() => new Shellstone();

  /// Getter for the [QueryAdapters] adapters
  static Map<String,DatabaseAdapter> get adapters => new Shellstone()._adapters;
}
