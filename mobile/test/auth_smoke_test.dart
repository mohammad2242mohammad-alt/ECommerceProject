import 'package:flutter_test/flutter_test.dart';

import 'package:frontend/core/network/api_client.dart';
import 'package:frontend/core/storage/token_storage.dart';
import 'package:frontend/data/services/auth_service.dart';

void main() {
  test('AuthService can be created', () {
    final tokenStorage = TokenStorage();

    final apiClient = ApiClient(
      tokenStorage: tokenStorage,
    );

    final authService = AuthService(
      apiClient: apiClient,
      tokenStorage: tokenStorage,
    );

    expect(authService, isNotNull);
  });
}