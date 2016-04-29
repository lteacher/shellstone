part of shellstone;

/// The shellstone singleton. When setup is called the lazy initialisation
/// will be triggered
class Shellstone {
  // Metadata singleton
  static final Shellstone _stone = new Shellstone._internal();
  final Map<String, DatabaseAdapter> _adapters = new Map();

  factory Shellstone() => _stone;

  Shellstone._internal() {
    // Scan and build metadata
    new Metadata().scan();

    // Add any base adapters, theres one one and its a mock at the moment
    _adapters['mock'] = new MockDatabaseAdapter();
  }

  /// The setup method will launch Shellstone.
  ///
  /// On launch, all Annotations are scanned in. The defaults for the
  /// framework are setup and can be overridden via the provided accessors
  static Future setup() => new Shellstone()._runStartupTasks();

  /// Getter for the [QueryAdapters] adapters
  static Map<String, DatabaseAdapter> get adapters =>
      new Shellstone()._adapters;

  // Sets up all the requirements to run
  Future _runStartupTasks() {
    StreamController ctrl = new StreamController.broadcast();

    // Add the adaptor processors in
    var processors = _addAdapterProcessors(ctrl);

    // Add the events to the pipe
    ctrl.add('configure');
    ctrl.add('connect');
    ctrl.add('build');

    // Return
    return Future.wait(processors);
  }

  // Adds all the adapter processors as listeners
  List _addAdapterProcessors(StreamController ctrl) {
    var results = [];
    _adapters.forEach((key, val) {
      results.add(ctrl.stream
          .listen(new AdapterEvent(key).process)
          .asFuture());
    });

    return results;
  }
}
