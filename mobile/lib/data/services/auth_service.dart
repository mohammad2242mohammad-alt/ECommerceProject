import '../../core/constants/api_constants.dart';
import '../../core/network/api_client.dart';
import '../../core/storage/token_storage.dart';
import '../models/user_model.dart';

class AuthService {
  AuthService({
    ApiClient? apiClient,
    TokenStorage? tokenStorage,
  })  : _apiClient = apiClient ?? ApiClient(),
        _tokenStorage = tokenStorage ?? TokenStorage();

  final ApiClient _apiClient;
  final TokenStorage _tokenStorage;

  Future<Map<String, dynamic>> register({
    required String phone,
    required String password,
  }) async {
    final response = await _apiClient.post<Map<String, dynamic>>(
      ApiConstants.register,
      body: {
        'phone': phone,
        'password': password,
      },
    );

    final data = response.data ?? {};

    final token = data['token'] as String?;

    if (token != null && token.isNotEmpty) {
      await _tokenStorage.saveToken(token);
    }

    return data;
  }

  Future<Map<String, dynamic>> login({
    required String phone,
    required String password,
  }) async {
    final response = await _apiClient.post<Map<String, dynamic>>(
      ApiConstants.login,
      body: {
        'phone': phone,
        'password': password,
      },
    );

    final data = response.data ?? {};

    final token = data['token'] as String?;

    if (token != null && token.isNotEmpty) {
      await _tokenStorage.saveToken(token);
    }

    return data;
  }

  Future<UserModel> me() async {
    final response = await _apiClient.get<Map<String, dynamic>>(
      ApiConstants.me,
    );

    final data = response.data ?? {};
    final userJson = data['user'] as Map<String, dynamic>;

    return UserModel.fromJson(userJson);
  }

  Future<void> logout() async {
    try {
      await _apiClient.post<Map<String, dynamic>>(
        ApiConstants.logout,
      );
    } finally {
      await _tokenStorage.removeToken();
    }
  }
}