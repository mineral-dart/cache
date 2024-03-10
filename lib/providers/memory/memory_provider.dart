import 'package:mineral/domains/cache/contracts/cache_provider_contract.dart';
import 'package:mineral/api/common/snowflake.dart';

final class MemoryProvider implements CacheProviderContract<Snowflake> {
  final Map<Snowflake, dynamic> _storage = {};

  @override
  String get name => 'InMemoryProvider';

  @override
  int get length => _storage.length;

  @override
  Map<Snowflake, T> getAll<T extends dynamic>() => _storage as Map<Snowflake, T>;

  @override
  T? get<T>(Snowflake? key) => _storage[key];

  @override
  T getOrFail<T>(Snowflake key, {Exception Function()? onFail}) {
    if (!_storage.containsKey(key)) {
      if (onFail case Function()) {
        throw onFail!();
      }

      throw Exception('Key $key not found');
    }
    return _storage[key];
  }

  @override
  bool has(Snowflake key) =>  _storage.containsKey(key);

  @override
  void put<T>(Snowflake key, T object) {
    _storage[key] = object;
  }

  @override
  void remove(Snowflake key) {
    _storage.remove(key);
  }

  @override
  void removeMany(List<Snowflake> keys) {
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
