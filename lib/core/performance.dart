/// Backoff retry for transient failures, and a small
/// in memory memo cache for pure calculations. Both are pure
/// Dart, no Flutter, no network. No user data is ever logged.
class BackoffRetry {
  BackoffRetry._();

  /// Runs [work] up to [maxAttempts] times. Retries only when
  /// [shouldRetry] says so; by default every error except
  /// ArgumentError is retried, since an ArgumentError is a
  /// caller bug, not a transient failure. Waits
  /// [delay] then doubles it after each failed attempt.
  static Future<T> run<T>(
    Future<T> Function() work, {
    int maxAttempts = 3,
    Duration delay = const Duration(milliseconds: 200),
    bool Function(Object error)? shouldRetry,
  }) async {
    assert(maxAttempts >= 1);
    Duration wait = delay;
    Object? lastError;
    for (int attempt = 1; attempt <= maxAttempts; attempt++) {
      try {
        return await work();
      } catch (error) {
        lastError = error;
        final bool retry = shouldRetry == null
            ? error is! ArgumentError
            : shouldRetry(error);
        if (!retry || attempt == maxAttempts) rethrow;
        await Future<void>.delayed(wait);
        wait *= 2;
      }
    }
    throw lastError!;
  }
}

/// Result of a timed measurement: the value plus how long the
/// work took, in whole milliseconds.
class Timed<T> {
  const Timed(this.value, this.elapsedMs);

  final T value;
  final int elapsedMs;
}

/// Measures synchronous work. Use for calculation timings in
/// tests and in the performance report, never for user timings
/// that carry personal data.
Timed<T> measureSync<T>(T Function() work) {
  final Stopwatch watch = Stopwatch()..start();
  final T value = work();
  watch.stop();
  return Timed<T>(value, watch.elapsedMilliseconds);
}

/// Measures asynchronous work the same way.
Future<Timed<T>> measure<T>(Future<T> Function() work) async {
  final Stopwatch watch = Stopwatch()..start();
  final T value = await work();
  watch.stop();
  return Timed<T>(value, watch.elapsedMilliseconds);
}

/// Small bounded memo cache for pure calculations. Oldest
/// entries drop out once [maxEntries] is reached. Keys must
/// already be safe strings built from inputs, never raw user
/// data such as names or emails.
class MemoCache<K, V> {
  MemoCache({this.maxEntries = 64});

  final int maxEntries;
  final Map<K, V> _entries = <K, V>{};
  int hits = 0;
  int misses = 0;

  V? get(K key) {
    final V? value = _entries[key];
    if (value == null) {
      misses++;
      return null;
    }
    hits++;
    return value;
  }

  void put(K key, V value) {
    if (_entries.length >= maxEntries && !_entries.containsKey(key)) {
      _entries.remove(_entries.keys.first);
    }
    _entries[key] = value;
  }

  void invalidate(K key) => _entries.remove(key);

  void clear() {
    _entries.clear();
    hits = 0;
    misses = 0;
  }

  int get length => _entries.length;
}
