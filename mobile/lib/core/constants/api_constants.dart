class ApiConstants {
  ApiConstants._();

  static const String baseUrl = 'http://127.0.0.1:8000/api';

  // Auth
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String logout = '/auth/logout';
  static const String me = '/auth/me';

  // Products
  static const String products = '/products';

  // Categories
  static const String categories = '/categories';
}