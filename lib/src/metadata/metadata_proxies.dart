import 'dart:mirrors';
import 'annotations.dart';

abstract class MetadataProxy {
  ClassMirror ref;
  MetadataProxy(this.ref);
}

/// Wraps a model by combining the [Model], reflectee and [Attr]ibutes
class ModelMetadata extends MetadataProxy {
  Model model;
  Map<String, Attr> attributes = new Map();
  Map<String, Rel> relations = new Map();
  ModelMetadata(ref, this.model) : super(ref);
}

/// Wraps a adapter by combining the [Adapter] and reflectee
class AdapterMetadata extends MetadataProxy {
  Adapter adapter;
  InstanceMirror instance;
  AdapterMetadata(ref, this.adapter) : super(ref) {
    instance = ref.newInstance(const Symbol(''), new List());
  }
}
