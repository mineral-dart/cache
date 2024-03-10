import 'package:mineral/domains/cache/contracts/cache_provider_contract.dart';
import 'package:mineral/api/common/snowflake.dart';

final class MemoryProvider implements CacheProviderContract<Snowflake> {
  final Map<Snowflake, dynamic> _storage = {};

  @override
  String get name => 'InMemoryProvider';

  @override
  Future<int> length() async => _storage.length;

  @override
  Future<Map<Snowflake, T>> getAll<T extends dynamic>() async => _storage as Map<Snowflake, T>;

  @override
  Future<T?> get<T>(Snowflake? key) async => _storage[key];

  @override
  Future<T> getOrFail<T>(Snowflake key, {Exception Function()? onFail}) async {
    if (!_storage.containsKey(key)) {
      if (onFail case Function()) {
        throw onFail!();
      }

      throw Exception('Key $key not found');
    }
    return _storage[key];
  }

  @override
  Future<bool> has(Snowflake key) async => _storage.containsKey(key);

  @override
  Future<void> put<T>(Snowflake key, T object) async {
    _storage[key] = object;
  }

  @override
  Future<void> remove(Snowflake key) async {
    _storage.remove(key);
  }

  @override
  Future<void> removeMany(List<Snowflake> keys) async {
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
