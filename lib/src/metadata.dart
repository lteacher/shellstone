part of shellstone;

/// Encapsulates the utility functions of looking up model annotated data
///
/// The [Metadata] class scans the libraries on startup using mirrors to find
/// the Shellstone relevant annotations and their reflectees. These are captured
/// so that they can be looked up later for various uses throughout the framework
/// most methods are static but leverage the underlying singleton. This means
/// the ugly new keyword style can be hidden from the consumers
class Metadata {
  // Metadata singleton
  static final Metadata _meta = new Metadata._internal();
  factory Metadata() => _meta;
  Metadata._internal();
  MetadataScanner _scanner;

  /// Returns the [ModelProxy] for some given [name]
  static ModelProxy proxy(String name) => _modelProxy(name);

  /// Lookup a [Model] object by [name]
  static Model model(String name) => _modelProxy(name).model;

  /// Returns the attributes Map for the model [name]
  static Map<String, Attr> attr(String name) => _modelProxy(name).dependents;

  /// Returns the name for the entity or list of entities
  static String name(dynamic entity) {
    if (entity is List) entity = entity[0];

    ClassMirror m = reflect(entity).type;
    var name = MirrorSystem.getName(m.simpleName);
    var proxy = _modelProxy(name); // Trigger a exception if non-existent

    return name;
  }

  /// Returns the [DBAdapter] metadata by [name]
  static DBAdapter adapter(String name) => _adapterProxy(name).adapter;

  /// Returns the [DBAdapter] @event handlers for a given adapter [name]
  static Map<String, dynamic> handlers(String name) => _adapterProxy(name).dependents;

  /// Wraps an [entity] into its mapped [Model] view, e.g. converts it to its annotated
  /// form as a map of key values.
  static Map<String, dynamic> wrap(dynamic entity) =>
      new EntityWrapper(entity: entity).wrap();

  /// Unwraps an entity from its mapped [Model] form.
  static dynamic unwrap(String name, Map<String, dynamic> map) =>
      new EntityWrapper(name: name).unwrap(map);

  /// Scans for relevant metadata. This needs to be called to setup the object
  /// as otherwise lazy initialisation would occur and not be desirable
  scan() {
    _scanner = new MetadataScanner._scan();
  }

  // Utility to retrieve a Model proxy out
  static _modelProxy(name) {
    var proxy = _meta._scanner.models[name];

    return proxy != null ? proxy : throw 'Unknown model type $name';
  }

  // Utility to retrieve an Adapter proxy out
  static _adapterProxy(name) {
    var proxy = _meta._scanner.adapters[name];

    return proxy != null ? proxy : throw 'Unknown adapter $name';
  }
}

abstract class MetaProxy {
  ClassMirror ref;
  Map<String, dynamic> dependents = new Map();
  MetaProxy(this.ref);
}

/// Wraps a model by combining the [Model], reflectee and [Attr]ibutes
class ModelProxy extends MetaProxy {
  Model model;
  ModelProxy(ref, this.model) : super(ref);
}

/// Wraps a adapter by combining the [DBAdapter], reflectee and [DBEventMeta]
class AdapterProxy extends MetaProxy {
  DBAdapter adapter;
  InstanceMirror instance;
  AdapterProxy(ref, this.adapter) : super(ref) {
    instance = ref.newInstance(const Symbol(''), new List());
  }
}

/// Scans the mirror system looking for Shellstone annotations
class MetadataScanner {
  Map<String, ModelProxy> models = new Map();
  Map<String, AdapterProxy> adapters = new Map();

  MetadataScanner._scan() {
    var mirrorSystem = currentMirrorSystem();
    var libs = mirrorSystem.libraries;

    // For each library, load the models
    // NOTE that this only does local files at the moment but easily changed
    // down in the _isScannable method
    libs.forEach(_loadModels);
  }

  // Load all models
  _loadModels(Uri uri, LibraryMirror lib) {
    // For each declaration mirror
    if (_isScannable(uri)) lib.declarations.forEach(_extractMetadata);
  }

  // Extract metadata out
  _extractMetadata(Symbol sym, DeclarationMirror m, [proxy]) {
    var name = MirrorSystem.getName(sym);
    var meta = m.metadata;

    // Ensure that the declaration has metadata
    if (meta.isEmpty) return;

    // Should be compiler error for lack of reflectee outside
    var reflectee = meta.first.reflectee;

    if (reflectee is Model || reflectee is DBAdapter)
      _addProxy(name, m, reflectee);
    if (reflectee is Attr) proxy.dependents[name] = reflectee;
    if (reflectee is DBEventMeta) {
      proxy.dependents[reflectee.name] = _getEventMethod(proxy.instance, sym);
    }
  }

  // Returns an annotated method for an event
  _getEventMethod(InstanceMirror obj, Symbol name) {
    var method = obj.getField(name).reflectee;
    return method is DBEventHandler
        ? method
        : throw 'The annotated method `${MirrorSystem.getName(name)}` is not a valid handler';
  }

  // Convenience method to add a metadata proxy, and reflectee to a collection
  Map _addProxy(name, m, r) {
    var map;
    MetaProxy proxy;

    if (r.runtimeType == Model) {
      map = models;
      proxy = new ModelProxy(m, r);
    }
    if (r.runtimeType == DBAdapter) {
      map = adapters;
      name = r.name;
      proxy = new AdapterProxy(m, r);
    }

    if (map.containsKey(name))
      throw 'Duplicate ${m.runtimeType.toString()} defined with name `$name`';

    map[name] = proxy;

    // Recursively add the add attributes
    ClassMirror cl = m;
    cl.declarations.forEach((s, d) => _extractMetadata(s, d, proxy));

    return map;
  }

  // Check if a lib is scannable
  bool _isScannable(Uri uri) {
    String name = uri.toString();

    // As of right now, Only local files are included as defining models
    // return name.startsWith('file');

    // OR we can just ignore at least dart uri's
    return !name.startsWith('dart');
  }
}
