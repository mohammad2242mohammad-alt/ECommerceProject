import '../../core/constants/api_constants.dart';
import '../../core/network/api_client.dart';
import '../../core/storage/local_storage.dart';
import '../models/address_model.dart';
import '../models/cart_model.dart';
import '../models/category_model.dart';
import '../models/home_model.dart';
import '../models/model_helpers.dart';
import '../models/order_model.dart';
import '../models/product_detail_model.dart';
import '../models/product_model.dart';
import '../models/review_model.dart';

class CheckoutSummary {
  const CheckoutSummary({required this.subtotal, required this.discount, required this.shipping, required this.total, this.couponCode});
  final num subtotal;
  final num discount;
  final num shipping;
  final num total;
  final String? couponCode;
  factory CheckoutSummary.fromJson(Map<String, dynamic> json) => CheckoutSummary(
        subtotal: asDouble(json['subtotal']) ?? 0,
        discount: asDouble(json['discount'] ?? json['discount_total']) ?? 0,
        shipping: asDouble(json['shipping'] ?? json['shipping_total']) ?? 0,
        total: asDouble(json['total']) ?? 0,
        couponCode: asMap(json['coupon'])['code']?.toString(),
      );
}

class StoreRepository {
  StoreRepository(this._api, this._storage);
  final ApiClient _api;
  final LocalStorage _storage;

  Future<HomeModel> getHome() async => HomeModel.fromJson(asMap((await _api.get<dynamic>(ApiConstants.home)).data));

  Future<List<Category>> getCategories() async {
    final data = (await _api.get<dynamic>(ApiConstants.categories)).data;
    return _list(data).map((item) => Category.fromJson(asMap(item))).toList();
  }

  Future<ProductsPage> getProducts(ProductQuery query) async {
    final params = <String, String>{
      'page': '${query.page}', 'per_page': '${query.perPage}',
      if (query.categoryId != null) 'category_id': '${query.categoryId}',
      if (query.search != null && query.search!.trim().isNotEmpty) 'search': query.search!.trim(),
      if (query.sort != null) 'sort': query.sort!,
      if (query.minPrice != null) 'min_price': '${query.minPrice}',
      if (query.maxPrice != null) 'max_price': '${query.maxPrice}',
    };
    final data = (await _api.get<dynamic>(ApiConstants.products, queryParameters: params)).data;
    return ProductsPage.fromJson(asMap(data));
  }

  Future<ProductDetailModel> getProduct(int id) async => ProductDetailModel.fromJson(asMap((await _api.get<dynamic>(ApiConstants.product(id))).data));

  Future<List<ReviewModel>> getReviews(int productId) async {
    final data = (await _api.get<dynamic>(ApiConstants.productReviews(productId))).data;
    return _list(data).map((item) => ReviewModel.fromJson(asMap(item))).toList();
  }

  Future<AuthSession> login(String phone, String password) => _auth(ApiConstants.authLogin, phone, password);

  Future<AuthSession> register(String phone, String password, String confirmation) async {
    return _auth(ApiConstants.authRegister, phone, password, confirmation: confirmation);
  }

  Future<AuthSession> _auth(String endpoint, String phone, String password, {String? confirmation}) async {
    final data = asMap((await _api.post<dynamic>(endpoint, body: {
      'phone': phone.trim(), 'password': password,
      if (confirmation != null) 'password_confirmation': confirmation,
    })).data);
    final session = AuthSession(user: UserModel.fromJson(asMap(data['user'])), token: data['token']?.toString() ?? '');
    await _storage.write('auth_token', session.token);
    return session;
  }

  Future<UserModel> me() async => UserModel.fromJson(asMap(asMap((await _api.get<dynamic>(ApiConstants.authMe)).data)['user']));

  Future<void> logout() async {
    try { await _api.post<dynamic>(ApiConstants.authLogout); } finally { await _storage.delete('auth_token'); }
  }

  Future<CartModel?> getCart() async {
    final data = (await _api.get<dynamic>(ApiConstants.cart)).data;
    return data == null ? null : CartModel.fromJson(asMap(data));
  }

  Future<CartModel?> addToCart({required int productId, int? variantId, int quantity = 1}) async {
    final data = (await _api.post<dynamic>(ApiConstants.cartItems, body: {
      'product_id': productId, if (variantId != null) 'variant_id': variantId, 'quantity': quantity,
    })).data;
    return data == null ? null : CartModel.fromJson(asMap(data));
  }

  Future<void> updateCartItem(int id, int quantity) async { await _api.put<dynamic>(ApiConstants.cartItem(id), body: {'quantity': quantity}); }
  Future<void> deleteCartItem(int id) async { await _api.delete<dynamic>(ApiConstants.cartItem(id)); }
  Future<void> clearCart() async { await _api.delete<dynamic>(ApiConstants.cart); }

  Future<List<AddressModel>> getAddresses() async {
    final data = (await _api.get<dynamic>(ApiConstants.addresses)).data;
    return _list(data).map((item) => AddressModel.fromJson(asMap(item))).toList();
  }

  Future<AddressModel> saveAddress(Map<String, dynamic> body, {int? id}) async {
    final data = (await (id == null
        ? _api.post<dynamic>(ApiConstants.addresses, body: body)
        : _api.put<dynamic>(ApiConstants.address(id), body: body))).data;
    return AddressModel.fromJson(asMap(data));
  }

  Future<void> deleteAddress(int id) async { await _api.delete<dynamic>(ApiConstants.address(id)); }

  Future<CheckoutSummary> calculateCheckout({String? couponCode}) async {
    final data = (await _api.post<dynamic>(ApiConstants.checkoutCalculate, body: {
      if (couponCode != null && couponCode.trim().isNotEmpty) 'coupon_code': couponCode.trim(),
    })).data;
    return CheckoutSummary.fromJson(asMap(data));
  }

  Future<CheckoutSummary> validateCoupon(String code) async {
    final data = (await _api.post<dynamic>(ApiConstants.couponValidate, body: {'code': code.trim()})).data;
    return CheckoutSummary.fromJson(asMap(data));
  }

  Future<OrderModel> createOrder(int addressId, {String? couponCode}) async {
    final data = (await _api.post<dynamic>(ApiConstants.orders, body: {
      'address_id': addressId,
      if (couponCode != null && couponCode.trim().isNotEmpty) 'coupon_code': couponCode.trim(),
    })).data;
    return OrderModel.fromJson(asMap(data));
  }

  Future<List<OrderModel>> getOrders() async {
    final data = (await _api.get<dynamic>(ApiConstants.orders)).data;
    return _list(data).map((item) => OrderModel.fromJson(asMap(item))).toList();
  }

  Future<OrderModel> getOrder(int id) async => OrderModel.fromJson(asMap((await _api.get<dynamic>(ApiConstants.order(id))).data));
  Future<OrderModel> cancelOrder(int id) async => OrderModel.fromJson(asMap((await _api.post<dynamic>(ApiConstants.cancelOrder(id))).data));

  Future<OrderModel> startPayment(int id, {String simulate = 'success'}) async {
    final data = asMap((await _api.post<dynamic>(ApiConstants.startPayment(id), body: {'simulate': simulate})).data);
    return OrderModel.fromJson(asMap(data['order']));
  }

  Future<List<ProductModel>> getFavorites() async {
    final data = (await _api.get<dynamic>(ApiConstants.favorites)).data;
    return _list(data).map((item) {
      final map = asMap(item);
      return ProductModel.fromJson(asMap(map['product'] is Map ? map['product'] : map));
    }).toList();
  }

  Future<void> addFavorite(int productId) async { await _api.post<dynamic>(ApiConstants.favorites, body: {'product_id': productId}); }
  Future<void> removeFavorite(int productId) async { await _api.delete<dynamic>(ApiConstants.favoriteProduct(productId)); }

  Future<void> submitReview(int productId, {required int rating, String? title, required String body}) async { await _api.post<dynamic>(ApiConstants.productReviews(productId), body: {'rating': rating, if (title != null && title.trim().isNotEmpty) 'title': title.trim(), 'body': body.trim()}); }

  List<dynamic> _list(dynamic data) {
    if (data is List) return data;
    final map = asMap(data);
    if (map['items'] is List) return map['items'] as List;
    if (map['data'] is List) return map['data'] as List;
    return const [];
  }
}
