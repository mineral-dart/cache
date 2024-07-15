import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:mineral/api/common/snowflake.dart';
import 'package:mineral/infrastructure/internals/environment/environment.dart';
import 'package:mineral/infrastructure/internals/cache/cache_provider_contract.dart';
import 'package:mineral/infrastructure/services/logger/logger.dart';
import 'package:mineral_cache/providers/redis/redis_env_keys.dart';
import 'package:mineral_cache/providers/redis/redis_settings.dart';
import 'package:redis/redis.dart';

final class RedisProvider implements CacheProviderContract {
  final RedisConnection _connection = RedisConnection();

  late final RedisSettings settings;

  @override
  late final LoggerContract logger;

  RedisProvider({required String host, required int port, String? password}) {
    settings = RedisSettings(host, port, password);
  }

  @override
  String get name => 'RedisProvider';

  @override
  Future<void> init() async {
    try {
      await _connection.connect(settings.host, settings.port);

      final Map<String, dynamic> credentials = {
        'service': 'cache',
        'message': 'redis is connected',
        'payload': {
          'host': settings.host,
          'port': settings.port,
          'password': settings.password != null ? '*' * settings.password!.length : 'NO PASSWORD',
        },
      };

      logger.trace(jsonEncode(credentials));
    } on SocketException catch (error) {
      logger.fatal(error);
      throw Exception('$name - ${error.message}');
    }
  }

  @override
  Future<int> length() async {
    final value = await Command(_connection).send_object(['SCAN', 0]);
    return switch (value) {
      List() => value.length,
      String() => int.parse(value),
      _ => value,
    };
  }

  @override
  Future<List<Map<String, dynamic>>> getAll() async {
    final keys = await Command(_connection).send_object(['KEYS', '*']);
    final values = await Command(_connection).send_object(['MGET', ...keys]);

    return List.from(values.map((e) => jsonDecode(e)));
  }

  @override
  Future<Map<String, dynamic>?> get(String? key) async {
    final value = await Command(_connection).get(key ?? '');
    return switch (value) {
      String() => jsonDecode(value),
      _ => value,
    };
  }

  @override
  Future<Map<String, dynamic>> getOrFail(String key, {Exception Function()? onFail}) async {
    final value = await get(key);
    if (value == null) {
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

  factory RedisProvider.fromEnvironment(EnvContract env) {
    env.validate(RedisEnvKeys.values);

    return RedisProvider(
      host: env.get(RedisEnvKeys.redisHost),
      port: int.parse(env.get(RedisEnvKeys.redisPort)),
      password: env.get(RedisEnvKeys.redisPassword),
    );
  }
}
