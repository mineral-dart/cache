import 'dart:convert';

import 'package:mineral/domains/cache/contracts/cache_provider_contract.dart';
import 'package:mineral/infrastructure/services/logger/logger.dart';

final class MemoryProvider implements CacheProviderContract<String> {
  final Map<String, dynamic> _storage = {};

  @override
  late final LoggerContract logger;

  @override
  Future<void> init() async {
    final Map<String, dynamic> credentials = {
      'service': 'cache',
      'message': 'memory is used',
      'payload': {},
    };

    logger.trace(jsonEncode(credentials));
  }

  @override
  String get name => 'InMemoryProvider';

  @override
  Future<int> length() async => _storage.length;

  @override
  Future<List<T>> getAll<T extends dynamic>() async => List.from(_storage.values);

  @override
  Future<T?> get<T>(String? key) async => _storage[key];

  @override
  Future<T> getOrFail<T>(String key, {Exception Function()? onFail}) async {
    if (!_storage.containsKey(key)) {
      if (onFail case Function()) {
        throw onFail!();
      }

      throw Exception('Key $key not found');
    }
    return _storage[key];
  }

  @override
  Future<bool> has(String key) async => _storage.containsKey(key);

  @override
  Future<void> put<T>(String key, T object) async {
    _storage[key] = object;
  }

  @override
  Future<void> remove(String key) async {
    _storage.remove(key);
  }

  @override
  Future<void> removeMany(List<String> keys) async {
    for (final key in keys) {
      _storage.remove(key);
    }
  }

  @override
  Future<void> clear() async => _storage.clear();

  @override
  Future<bool> getHealth() async => true;

  @override
  Future<void> dispose() async => _storage.clear();
}
