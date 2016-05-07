import 'dart:async';
import '../metadata/annotations.dart';

/// Defines a base [Model] that can be extended if a default id is desired
abstract class BaseModel {
  @Attr(primaryKey: true) int id;
  @Attr() DateTime created;
  @Attr() DateTime updated;
}

/// Defines a [Model] mixin that can implement some transactional functionality
abstract class TransactionModel {
  Future save();
  Future rollback();
}
