import 'dart:async';

/// A utility class to limit the number of concurrent asynchronous operations.
class LimitConcurrency {
  /// Creates a [LimitConcurrency] instance with a maximum of [maxConcurrent] tasks running simultaneously.
  LimitConcurrency(this.maxConcurrent);

  final int maxConcurrent;
  int _current = 0;
  final List<Function()> _queue = [];

  /// Runs the given [task] function, ensuring that no more than [maxConcurrent] tasks are running at the same time.
  Future<T> run<T>(Future<T> Function() task) {
    if (_current < maxConcurrent) {
      _current++;
      return task().whenComplete(() {
        _current--;
        _runNext();
      });
    } else {
      final completer = Completer<T>();
      _queue.add(() => run(task).then(completer.complete).catchError(completer.completeError));
      return completer.future;
    }
  }

  void _runNext() {
    if (_queue.isNotEmpty && _current < maxConcurrent) {
      final nextTask = _queue.removeAt(0);
      nextTask();
    }
  }
}
