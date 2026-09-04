import 'local_storage.dart';

/// Token storage that requires no extra package. It lasts for this app session.
class MemoryStorage implements LocalStorage {
  final Map<String, dynamic> _storage = {};
  @override
  Future<void> write(String key, dynamic value) async { _storage[key] = value; }
  @override
  Future<dynamic> read(String key) async => _storage[key];
  @override
  Future<void> delete(String key) async { _storage.remove(key); }
  @override
  Future<void> clear() async => _storage.clear();
}
