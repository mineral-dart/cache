import 'dart:convert';

import 'package:mineral/domains/cache/contracts/cache_provider_contract.dart';
import 'package:mineral_cache/providers/redis/redis_settings.dart';
import 'package:redis/redis.dart';

final class RedisProvider implements CacheProviderContract<String> {
  final RedisConnection _connection = RedisConnection();
  late final RedisSettings settings;

  RedisProvider({required String host, required int port, String? password}) {
    settings = RedisSettings(host, port, password);
  }

  @override
  String get name => 'RedisProvider';

  @override
  Future<void> init() async {
    await _connection.connect('localhost', 6379);
  }

  @override
  Future<int> length() async {
    final value = await Command(_connection).send_object(['SCAN', 0]);
    return switch(value) {
      List() => value.length,
      String() => int.parse(value),
      _ => value,
    };
  }

  @override
  Future<List<T>> getAll<T extends dynamic>() async {
    final keys = await Command(_connection).send_object(['KEYS', '*']);
    final values = await Command(_connection).send_object(['MGET', ...keys]);

    return List.from(values.map((e) => jsonDecode(e)));
  }

  @override
  Future<T?> get<T>(String? key) async {
    final value = await Command(_connection).get(key ?? '');
    return switch (value) {
      String() => jsonDecode(value),
      _ => value,
    };
  }

  @override
  Future<T> getOrFail<T>(String key, {Exception Function()? onFail}) async {
    final value = await get(key);
    if (!value) {
      if (onFail case Function()) {
        throw onFail!();
      }

      throw Exception('Key $key not found');
    }
    return value;
  }

  @override
  Future<bool> has(String key) async {
    final result = await Command(_connection).send_object(['EXISTS', key]);
    return switch (result) {
      0 => false,
      _ => true,
    };
  }

  @override
  Future<void> put<T>(String key, T object) async {
    await Command(_connection).send_object(['SET', key, jsonEncode(object)]);
  }

  @override
  Future<void> remove(String key) async {
    return Command(_connection).send_object(['DEL', key]);
  }

  @override
  Future<void> removeMany(List<String> keys) async {
    await Command(_connection).send_object(['DEL', ...keys]);
  }

  @override
  Future<void> clear() async {
    return Command(_connection).send_object(['FLUSHALL']);
  }

  @override
  Future<bool> getHealth() async {
    final value = await Command(_connection).send_object(['PING']);
    return value == 'PONG';
  }

  @override
  Future<void> dispose() async {
    await _connection.close();
  }
}
