import 'package:mineral/infrastructure/internals/environment/env_schema.dart';

enum RedisEnvKeys implements EnvSchema {
  redisHost('REDIS_HOST'),
  redisPort('REDIS_PORT'),
  redisPassword('REDIS_PASSWORD', required: false);

  @override
  final String key;

  @override
  final bool required;

  const RedisEnvKeys(this.key, {this.required = true});
}
