import 'dart:mirrors';
import '../util/globals.dart';
import '../../shellstone.dart';

/// Scans the mirror system looking for Shellstone annotations
class MetadataScanner {
  Map<String, ModelMetadata> models = new Map();
  Map<String, AdapterMetadata> adapters = new Map();

  MetadataScanner.scan() {
    var mirrorSystem = currentMirrorSystem();
    var libs = mirrorSystem.libraries;

    // For each library, load the models
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

    // Handle Model annotation
    if (reflectee is Model)
      _addProxy(name, m, reflectee);

    // Handle adapter
    else if (reflectee is Adapter) {
      _addProxy(name, m, reflectee);

      // Drop the reflected adapter instance into the global
      // shellstone adapters (from shellstone.dart)
      addAdapter(
          reflectee.name, this.adapters[reflectee.name].instance.reflectee);
    }

    // Handle Attr annotations
    else if (reflectee is Attr)
      proxy.dependents[name] = reflectee;

    // Handle Listen or Hook types
    else if (reflectee is Handler) {
      LibraryMirror lm = m.owner;
      var fn = lm.getField(sym).reflectee;

      if (!(fn is HandlerFunction))
        throw 'Invalid handler `$name` provided for `${reflectee.runtimeType}`';
        
      // Set the handlers
      addHandler(reflectee.runtimeType, reflectee.reg, fn, reflectee.loc);
    }
  }

  // Convenience method to add a metadata proxy, and reflectee to a collection
  Map _addProxy(name, m, r) {
    var map;
    MetadataProxy proxy;

    if (r.runtimeType == Model) {
      map = models;
      proxy = new ModelMetadata(m, r);
    }
    if (r.runtimeType == Adapter) {
      map = adapters;
      name = r.name;
      proxy = new AdapterMetadata(m, r);
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
