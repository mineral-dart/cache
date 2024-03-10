import 'package:cache/providers/memory/memory_provider.dart';
import 'package:test/test.dart';
import 'package:mineral/api/common/snowflake.dart';

void main() {
  test('can create in-memory provider', () {
    final provider = MemoryProvider();
    expect(provider.name, 'InMemoryProvider');
  });

  test('can get elements', () {
    final provider = MemoryProvider();
    expect(provider.getAll(), hasLength(0));
  });

  test('can put elements', () {
    final provider = MemoryProvider();
    provider.put(Snowflake('key'), 'value');
    expect(provider.has(Snowflake('key')), true);
  });

  test('can remove elements', () {
    final provider = MemoryProvider();
    provider.put(Snowflake('key'), 'value');
    provider.remove(Snowflake('key'));
    expect(provider.has(Snowflake('key')), false);
  });

  test('can remove many elements', () {
    final provider = MemoryProvider();
    provider.put(Snowflake('key1'), 'value');
    provider.put(Snowflake('key2'), 'value2');

    provider.removeMany([Snowflake('key1'), Snowflake('key2')]);

    expect(provider.has(Snowflake('key1')), false);
    expect(provider.has(Snowflake('key2')), false);
  });
}
