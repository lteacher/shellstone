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
  static ModelProxy proxy(String name) => _proxy(name);

  /// Lookup a [Model] object by [name]
  static Model model(String name) => _proxy(name).model;

  /// Returns the attributes Map for the model [name]
  static Map<String, Attr> attr(String name) => _proxy(name).attributes;

  /// Returns the name for the entity or list of entities
  static String name(dynamic entity) {
    if (entity is List) entity = entity[0];

    ClassMirror m = reflect(entity).type;
    var name = MirrorSystem.getName(m.simpleName);
    var proxy = _proxy(name); // Trigger a exception if non-existent

    return name;
  }

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

  // Utility to retrieve the proxy out
  static _proxy(name) {
    var proxy = _meta._scanner.models[name];

    return proxy != null ? proxy : throw 'Unknown model type $name';
  }
}

/// Wraps a model by combining the model, reflectee and attributes
class ModelProxy {
  ClassMirror ref;
  Model model;
  Map<String, Attr> attributes = new Map();
  ModelProxy(this.ref, this.model);
}

/// Scans the mirror system looking for Shellstone annotations
class MetadataScanner {
  Map<String, ModelProxy> models = new Map();

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
  _extractMetadata(Symbol sym, DeclarationMirror m, [ModelProxy proxy]) {
    var name = MirrorSystem.getName(sym);
    var meta = m.metadata;

    // Ensure that the declaration has metadata
    if (meta.isEmpty) return;

    // Should be compiler error for lack of reflectee outside
    var reflectee = meta.first.reflectee;

    // Found a Model here
    if (reflectee is Model) {
      if (models.containsKey(name))
        throw 'Duplicate model defined with name `$name`';

      models[name] = new ModelProxy(m, reflectee);

      // Recursively add the add attributes
      ClassMirror cl = m;
      cl.declarations.forEach((s, d) => _extractMetadata(s, d, models[name]));
    } else if (reflectee is Attr) {
      proxy.attributes[name] = reflectee;
    }
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
