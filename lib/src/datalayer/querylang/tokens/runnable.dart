import 'dart:async';

/// A Runnable class
abstract class Runnable {
  dynamic run();
}

/// Defines a [Runnable] which returns a [Future<dynamic>] with the single result
abstract class SingleResultRunnable extends Runnable {
  /// Runs the query chain producing an async result
  Future<dynamic> run();
}

/// Defines a [Runnable] which returns a [Future<List>] of multiple results
abstract class MultipleResultRunnable extends Runnable {
  /// Runs the query chain producing a List of results
  Future<List<dynamic>> run();
}
