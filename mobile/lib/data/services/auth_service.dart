import '../../core/constants/api_constants.dart';
import '../../core/network/api_client.dart';
import '../models/user_model.dart';

class AuthService {
  AuthService({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient();

  final ApiClient _apiClient;

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

    return response.data ?? {};
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

    return response.data ?? {};
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
    await _apiClient.post<Map<String, dynamic>>(
      ApiConstants.logout,
    );
  }
}