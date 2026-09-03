import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/repositories/auth_repository.dart';
import '../data/services/auth_service.dart';
import 'core_providers.dart';

final authServiceProvider = Provider<AuthService>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  final tokenStorage = ref.watch(tokenStorageProvider);

  return AuthService(
    apiClient: apiClient,
    tokenStorage: tokenStorage,
  );
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final authService = ref.watch(authServiceProvider);

  return AuthRepository(
    authService: authService,
  );
});