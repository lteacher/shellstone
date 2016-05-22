import 'dart:mirrors';
import 'metadata_proxies.dart';
import '../internal/globals.dart';
import '../entities/entity_builder.dart';
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

      // Handle Attr annotations
    } else if (reflectee is Attr)
      proxy.attributes[name] = reflectee;

    // Handle relations
    else if (reflectee is Rel)
      _addRelation(name, m, reflectee, proxy);

    // Handle Listen or Hook types
    else if (reflectee is Handler) {
      LibraryMirror lm = m.owner;
      var fn = lm.getField(sym).reflectee;

      if (!(fn is HandlerFunction))
        throw 'Invalid handler `$name` provided for `${reflectee.runtimeType}`';

      // Set the handlers
      addHandler(reflectee.runtimeType, reflectee.reg, fn);
    }
  }

  // Convenience method to add a metadata proxy, and reflectee to a collection
  Map _addProxy(name, m, r) {
    var map;
    MetadataProxy proxy;

    if (r.runtimeType == Model) {
      // If the model has no name give it the class name via copy
      if (r.name == null) r = new Model.copy(name.toLowerCase(), r);

      map = models;
      proxy = new ModelMetadata(m, r);

      // Load this type now
      EntityBuilder.loadMirror(m);
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

  // Adds a relation to the model proxy
  _addRelation(name, VariableMirror m, Rel r, proxy) {
    var model = r.model ?? _deriveType(m);
    r = new Rel.copy(r, model: model);

    proxy.relations[name] = new RelWrapper(r,_isCollection(m.type));
  }

  // Determines the type of some variable if possible
  _deriveType(VariableMirror m) {
    Type t = m.type.reflectedType;

    // Substitute the type if its there is a generic arg
    if (m.type.typeArguments.isNotEmpty) {
      t = m.type.typeArguments.first.reflectedType;
    }

    // This is the one scenario we know will not be valid on scan
    if (t == dynamic)
      throw 'Cannot infer type from `$t` for `Rel` with no `model`';

    // Else return as an acceptable type
    return t;
  }

  // Check if a typemirror is a collection
  _isCollection(TypeMirror m) => m.isAssignableTo((reflectType(Iterable)));

  // Check if a lib is scannable
  bool _isScannable(Uri uri) {
    String name = uri.toString();

    // As of right now, Only local files are included as defining models
    // return name.startsWith('file');

    // OR we can just ignore at least dart uri's
    return !name.startsWith('dart');
  }
}
