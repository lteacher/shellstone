import 'dart:mirrors';
import 'annotations.dart';

abstract class MetadataProxy {
  ClassMirror ref;
  Map<String, dynamic> dependents = new Map();
  MetadataProxy(this.ref);
}

/// Wraps a model by combining the [Model], reflectee and [Attr]ibutes
class ModelMetadata extends MetadataProxy {
  Model model;
  ModelMetadata(ref, this.model) : super(ref);
}

/// Wraps a adapter by combining the [DBAdapter], reflectee and [DBEventMeta]
class AdapterMetadata extends MetadataProxy {
  Adapter adapter;
  InstanceMirror instance;
  AdapterMetadata(ref, this.adapter) : super(ref) {
    instance = ref.newInstance(const Symbol(''), new List());
  }
}
