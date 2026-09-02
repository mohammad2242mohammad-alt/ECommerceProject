import '../models/user_model.dart';
import '../services/auth_service.dart';

class AuthRepository {
  AuthRepository({AuthService? authService})
      : _authService = authService ?? AuthService();

  final AuthService _authService;

  Future<Map<String, dynamic>> register({
    required String phone,
    required String password,
  }) {
    return _authService.register(
      phone: phone,
      password: password,
    );
  }

  Future<Map<String, dynamic>> login({
    required String phone,
    required String password,
  }) {
    return _authService.login(
      phone: phone,
      password: password,
    );
  }

  Future<UserModel> me() {
    return _authService.me();
  }

  Future<void> logout() {
    return _authService.logout();
  }
}