class ApiConstants {
  ApiConstants._();

  /// Override for a physical device/emulator without changing source code:
  /// flutter run --dart-define=API_BASE_URL=http://10.0.2.2:8000/api
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://127.0.0.1:8000/api',
  );

  static String mediaUrl(String? path) {
    if (path == null || path.trim().isEmpty) return '';
    final value = path.trim();
    if (value.startsWith('http://') || value.startsWith('https://')) return value;
    final base = Uri.parse(baseUrl);
    final origin = '${base.scheme}://${base.authority}';
    return value.startsWith('/') ? '$origin$value' : '$origin/$value';
  }

  static const authLogin = '/auth/login';
  static const authRegister = '/auth/register';
  static const authLogout = '/auth/logout';
  static const authMe = '/auth/me';
  static const home = '/home';
  static const categories = '/categories';
  static const products = '/products';
  static const cart = '/cart';
  static const cartItems = '/cart/items';
  static const addresses = '/addresses';
  static const checkoutCalculate = '/checkout/calculate';
  static const couponValidate = '/coupons/validate';
  static const orders = '/orders';
  static const favorites = '/favorites';
  static const banners = '/banners';
  static const settings = '/settings';

  static String product(int id) => '/products/$id';
  static String productReviews(int id) => '/products/$id/reviews';
  static String productAttributes(int id) => '/products/$id/attributes';
  static String productImages(int id) => '/products/$id/images';
  static String productVariants(int id) => '/products/$id/variants';
  static String cartItem(int id) => '/cart/items/$id';
  static String address(int id) => '/addresses/$id';
  static String order(int id) => '/orders/$id';
  static String cancelOrder(int id) => '/orders/$id/cancel';
  static String startPayment(int id) => '/payments/$id/start';
  static String paymentStatus(int id) => '/payments/$id/status';
  static String favoriteProduct(int id) => '/favorites/$id';
}
