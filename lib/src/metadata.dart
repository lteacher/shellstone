part of shellstone;

/// Encapsulates the utility functions of looking up model annotated data
///
/// The [Metadata] class scans the libraries on startup using mirrors to find
/// the Shellstone relevant annotations and their reflectees. These are captured
/// so that they can be looked up later for various uses throughout the framework
class Metadata {
  // Metadata singleton
  static final Metadata _meta = new Metadata._internal();
  factory Metadata() => _meta;
  Metadata._internal();
  MetadataScanner _scanner;

  /// Lookup a [Model] object by name
  ModelProxy model(String name) => _scanner.models[name];

  /// Scans for relevant metadata. This needs to be called to setup the object
  /// as otherwise lazy initialisation would occur and not be desirable
  scan() {
    _scanner = new MetadataScanner._scan();
  }
}

/// Wraps a model by combining the model, reflectee and attributes
class ModelProxy {
  ClassMirror ref;
  Model model;
  Map<String,Attr> attributes = new Map();
  ModelProxy(this.ref,this.model);
}

/// Scans the mirror system looking for
class MetadataScanner {
  Map<String,ModelProxy> models = new Map();

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
    if(_isScannable(uri)) lib.declarations.forEach(_extractMetadata);
  }

  // Extract metadata out
  _extractMetadata(Symbol sym, DeclarationMirror m, [ModelProxy proxy]) {
    var name = MirrorSystem.getName(sym);
    var meta = m.metadata;

    // Ensure that the declaration has metadata
    if(meta.isEmpty) return;

    // Should be compiler error for lack of reflectee outside
    var reflectee = meta.first.reflectee;

    // Found a Model here
    if(reflectee is Model) {
      if(models.containsKey(name)) throw 'Duplicate model defined with name `$name`';

      models[name] = new ModelProxy(m,reflectee);

      // Recursively add the add attributes
      ClassMirror cl = m;
      cl.declarations.forEach((s,d) => _extractMetadata(s,d,models[name]));
    } else if(reflectee is Attr) {
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
