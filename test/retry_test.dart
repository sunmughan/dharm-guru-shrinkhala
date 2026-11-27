import 'package:dharm_guru_shrinkhala/core/performance.dart';
import 'package:flutter_test/flutter_test.dart';

/// Phase 18, test IDs RET-01 to RET-05 and CACHE-01 to
/// CACHE-04. Retry behaviour and the memo cache that backs
/// calculation caching.
void main() {
  group('Retry.run', () {
    test('RET-01 returns the value when the first attempt works', () async {
      final String value = await Retry.run(
        () async => 'ok',
        delay: const Duration(milliseconds: 1),
      );
      expect(value, 'ok');
    });

    test('RET-02 retries a transient failure and then succeeds', () async {
      int attempts = 0;
      final String value = await Retry.run(() async {
        attempts++;
        if (attempts < 3) throw StateError('UNAVAILABLE');
        return 'ok';
      }, delay: const Duration(milliseconds: 1));
      expect(value, 'ok');
      expect(attempts, 3);
    });

    test('RET-03 gives up after maxAttempts and rethrows', () async {
      int attempts = 0;
      await expectLater(
        Retry.run(() async {
          attempts++;
          throw StateError('UNAVAILABLE');
        }, maxAttempts: 2, delay: const Duration(milliseconds: 1)),
        throwsStateError,
      );
      expect(attempts, 2);
    });

    test('RET-04 never retries an ArgumentError, a caller bug', () async {
      int attempts = 0;
      await expectLater(
        Retry.run(() async {
          attempts++;
          throw ArgumentError('bad input');
        }, delay: const Duration(milliseconds: 1)),
        throwsArgumentError,
      );
      expect(attempts, 1);
    });

    test('RET-05 honours a custom shouldRetry predicate', () async {
      int attempts = 0;
      await expectLater(
        Retry.run(
          () async {
            attempts++;
            throw StateError('PERMISSION_DENIED');
          },
          maxAttempts: 3,
          delay: const Duration(milliseconds: 1),
          shouldRetry: (Object e) => false,
        ),
        throwsStateError,
      );
      expect(attempts, 1);
    });
  });

  group('MemoCache', () {
    test('CACHE-01 miss then hit, with hit and miss counts', () {
      final MemoCache<String, int> cache = MemoCache<String, int>();
      expect(cache.get('a'), isNull);
      expect(cache.misses, 1);
      cache.put('a', 42);
      expect(cache.get('a'), 42);
      expect(cache.hits, 1);
    });

    test('CACHE-02 drops the oldest entry past maxEntries', () {
      final MemoCache<String, int> cache =
          MemoCache<String, int>(maxEntries: 2);
      cache.put('a', 1);
      cache.put('b', 2);
      cache.put('c', 3);
      expect(cache.length, 2);
      expect(cache.get('a'), isNull);
      expect(cache.get('c'), 3);
    });

    test('CACHE-03 invalidate removes one key only', () {
      final MemoCache<String, int> cache = MemoCache<String, int>();
      cache.put('a', 1);
      cache.put('b', 2);
      cache.invalidate('a');
      expect(cache.get('a'), isNull);
      expect(cache.get('b'), 2);
    });

    test('CACHE-04 clear empties the cache and resets counts', () {
      final MemoCache<String, int> cache = MemoCache<String, int>();
      cache.put('a', 1);
      cache.get('a');
      cache.clear();
      expect(cache.length, 0);
      expect(cache.hits, 0);
      expect(cache.misses, 0);
    });
  });
}
