import 'package:mineral/application/environment/environment_schema.dart';

enum RedisEnvKeys implements EnvironmentSchema {
  redisHost('REDIS_HOST'),
  redisPort('REDIS_PORT'),
  redisPassword('REDIS_PASSWORD');

  @override
  final String key;

  const RedisEnvKeys(this.key);
}
