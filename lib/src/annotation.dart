part of shellstone;

/// This annotation defines a Model which generally represents a table of
/// collection.
class Model {
  final String identity;
  final String connection;
  final bool autoCreatedAt;
  final bool autoUpdatedAt;

  const Model({
    this.identity,
    this.connection,
    this.autoCreatedAt,
    this.autoUpdatedAt
  });

  // static Future<dynamic> find(name) => Find('');
}

/// This annotation defines an attribute which is essentially the columns,
/// however, you can add additional properties.
class Attr {
  final String type;
  final String column;
  final bool primaryKey;

  const Attr({this.type,this.column,this.primaryKey});
}
