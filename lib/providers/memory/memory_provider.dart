import 'dart:convert';

import 'package:mineral/infrastructure/internals/cache/cache_provider_contract.dart';
import 'package:mineral/infrastructure/services/logger/logger.dart';

final class MemoryProvider implements CacheProviderContract {
  final Map<String, dynamic> _storage = {};

  @override
  late final LoggerContract logger;

  @override
  void init() {
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
  int length() => _storage.length;

  @override
  Map<String, dynamic> inspect() => _storage;

  @override
  Map<String, dynamic> whereKeyStartsWith(String prefix) {
    final entries = _storage.entries
        .where((element) => element.key.startsWith(prefix))
        .fold(<String, dynamic>{},
            (acc, element) => {...acc, element.key: element.value});

    return entries;
  }

  @override
  Map<String, dynamic> whereKeyStartsWithOrFail(String prefix,
      {Exception Function()? onFail}) {
    final entries = _storage.entries
        .where((element) => element.key.startsWith(prefix))
        .fold(<String, dynamic>{},
            (acc, element) => {...acc, element.key: element.value});

    return entries.isEmpty
        ? onFail != null
            ? throw onFail()
            : throw Exception('No keys found')
        : entries;
  }

  @override
  Map<String, dynamic>? get(String? key) => _storage[key];

  @override
  List<Map<String, dynamic>?> getMany(List<String> keys) {
    return keys
        .map((key) => _storage[key])
        .cast<Map<String, dynamic>?>()
        .toList();
  }

  @override
  Map<String, dynamic> getOrFail(String key, {Exception Function()? onFail}) {
    if (!_storage.containsKey(key)) {
      if (onFail case Function()) {
        throw onFail!();
      }

      throw Exception('Key $key not found');
    }
    return _storage[key];
  }

  @override
  bool has(String key) => _storage.containsKey(key);

  @override
  void put<T>(String key, T object) {
    _storage[key] = object;
  }

  @override
  void putMany<T>(Map<String, T> objects) {
    for (final element in objects.entries) {
      _storage[element.key] = element.value;
    }
  }

  @override
  void remove(String key) => _storage.remove(key);

  @override
  void removeMany(List<String> keys) {
    for (final key in keys) {
      _storage.remove(key);
    }
  }

  @override
  void clear() => _storage.clear();

  @override
  bool getHealth() => true;

  @override
  void dispose() => _storage.clear();
}
