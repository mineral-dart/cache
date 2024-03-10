import 'package:test/test.dart';
import 'package:mineral_cache/providers/memory/memory_provider.dart';

void main() {
  test('can create in-memory provider', () {
    final provider = MemoryProviderContract();
    expect(provider.name, 'InMemoryProvider');
  });

  test('can get elements', () {
    final provider = MemoryProviderContract();
    expect(provider.getAll(), hasLength(0));
  });

  test('can put elements', () {
    final provider = MemoryProviderContract();
    provider.put('key', 'value');
    expect(provider.has('key'), true);
  });

  test('can remove elements', () {
    final provider = MemoryProviderContract();
    provider.put('key', 'value');
    provider.remove('key');
    expect(provider.has('key'), false);
  });

  test('can remove many elements', () {
    final provider = MemoryProviderContract();
    provider.put('key', 'value');
    provider.put('key2', 'value2');

    provider.removeMany(['key', 'key2']);

    expect(provider.has('key'), false);
    expect(provider.has('key2'), false);
  });
}
