import 'dart:mirrors';
import 'annotations.dart';
import 'metadata_proxies.dart';

/// Scans the mirror system looking for Shellstone annotations
class MetadataScanner {
  Map<String, ModelMetadata> models = new Map();
  Map<String, AdapterMetadata> adapters = new Map();

  MetadataScanner.scan() {
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

    if (reflectee is Model || reflectee is Adapter)
      _addProxy(name, m, reflectee);
    if (reflectee is Attr) proxy.dependents[name] = reflectee;
    // if (reflectee is DBEventMeta) {
    //   proxy.dependents[reflectee.name] = _getEventMethod(proxy.instance, sym);
    // }
  }

  // // Returns an annotated method for an event
  // _getEventMethod(InstanceMirror obj, Symbol name) {
  //   var method = obj.getField(name).reflectee;
  //   return method is DBEventHandler
  //       ? method
  //       : throw 'The annotated method `${MirrorSystem.getName(name)}` is not a valid handler';
  // }

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
