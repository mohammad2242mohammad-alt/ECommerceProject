import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/network/api_client.dart';
import '../core/storage/local_storage.dart';
import '../core/storage/memory_storage.dart';

final apiClientProvider = Provider<ApiClient>((ref) {
  return ApiClient(storage: ref.watch(localStorageProvider));
});

final localStorageProvider = Provider<LocalStorage>((ref) {
  return MemoryStorage();
});
