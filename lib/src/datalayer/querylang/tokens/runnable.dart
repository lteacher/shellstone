import 'dart:async';

/// A Runnable class
abstract class Runnable {
  dynamic run();
}

/// Defines a [Runnable] which returns a [Future] with the single result
abstract class SingleResultRunnable extends Runnable {
  /// Runs the query chain producing an async result
  Future<dynamic> run();
}

/// Defines a [Runnable] which returns a [Stream] of multiple results
abstract class MultipleResultRunnable extends Runnable {
  /// Runs the query chain producing a Stream of async results
  Stream<dynamic> run();
}
