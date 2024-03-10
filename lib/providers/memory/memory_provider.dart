import 'package:mineral/domains/cache/contracts/cache_provider_contract.dart';

final class MemoryProviderContract implements CacheProviderContract {
  final Map<String, dynamic> _storage = {};

  @override
  String get name => 'InMemoryProvider';

  @override
  int get length => _storage.length;

  @override
  Map<String, T> getAll<T extends dynamic>() => _storage as Map<String, T>;

  @override
  T? get<T>(String? key) => _storage[key];

  @override
  T getOrFail<T>(String key, {Exception Function()? onFail}) {
    if (!_storage.containsKey(key)) {
      if (onFail case Function()) {
        throw onFail!();
      }

      throw Exception('Key $key not found');
    }
    return _storage[key];
  }

  @override
  bool has(String key) =>  _storage.containsKey(key);

  @override
  void put<T>(String key, T object) {
    _storage[key] = object;
  }

  @override
  void remove(String key) {
    _storage.remove(key);
  }

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
