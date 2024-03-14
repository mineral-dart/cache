import 'package:redis/redis.dart';

final class RedisStreamEvent<T> {
  final Command command;
  final String channel;
  final T data;

  RedisStreamEvent(this.command, this.channel, this.data);

  Future publish({ required String channel, required T data }) {
    return command.send_object(['PUBLISH', channel, data]);
  }
}
