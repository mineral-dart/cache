import 'package:mineral/domains/environment/env_schema.dart';

enum RedisEnvKeys implements EnvSchema {
  redisHost('REDIS_HOST'),
  redisPort('REDIS_PORT'),
  redisPassword('REDIS_PASSWORD');

  @override
  final String key;

  const RedisEnvKeys(this.key);
}
