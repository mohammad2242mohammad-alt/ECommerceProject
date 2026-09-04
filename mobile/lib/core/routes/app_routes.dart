import 'package:flutter/material.dart';

import '../../data/models/order_model.dart';
import '../../features/addresses/screens/addresses_screen.dart';
import '../../features/auth/screens/auth_screen.dart';
import '../../features/cart/screens/cart_screen.dart';
import '../../features/categories/screens/categories_screen.dart';
import '../../features/checkout/screens/checkout_screen.dart';
import '../../features/checkout/screens/payment_result_screen.dart';
import '../../features/favorites/screens/favorites_screen.dart';
import '../../features/home/screens/home_screen.dart';
import '../../features/orders/screens/order_detail_screen.dart';
import '../../features/orders/screens/orders_screen.dart';
import '../../features/products/screens/product_detail_screen.dart';
import '../../features/products/screens/products_screen.dart';
import '../../features/profile/screens/profile_screen.dart';

class AppRoutes {
  AppRoutes._();
  static const home = '/';
  static const auth = '/auth';
  static const categories = '/categories';
  static const products = '/products';
  static const productDetail = '/product-detail';
  static const cart = '/cart';
  static const addresses = '/addresses';
  static const checkout = '/checkout';
  static const paymentResult = '/payment-result';
  static const orders = '/orders';
  static const orderDetail = '/order-detail';
  static const favorites = '/favorites';
  static const profile = '/profile';

  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    final args = settings.arguments;
    switch (settings.name) {
      case home: return MaterialPageRoute(builder: (_) => const HomeScreen(), settings: settings);
      case auth: return MaterialPageRoute(builder: (_) => const AuthScreen(), settings: settings);
      case categories: return MaterialPageRoute(builder: (_) => const CategoriesScreen(), settings: settings);
      case products:
        final map = args is Map ? args : const <String, dynamic>{};
        return MaterialPageRoute(builder: (_) => ProductsScreen(categoryId: map['category_id'] as int?, initialSearch: map['search']?.toString(), title: map['title']?.toString()), settings: settings);
      case productDetail: return MaterialPageRoute(builder: (_) => ProductDetailScreen(productId: args is int ? args : int.tryParse(args?.toString() ?? '') ?? 0), settings: settings);
      case cart: return MaterialPageRoute(builder: (_) => const CartScreen(), settings: settings);
      case addresses:
        final map = args is Map ? args : const <String, dynamic>{};
        return MaterialPageRoute(builder: (_) => AddressesScreen(selectMode: map['select'] == true), settings: settings);
      case checkout: return MaterialPageRoute(builder: (_) => const CheckoutScreen(), settings: settings);
      case paymentResult: return MaterialPageRoute(builder: (_) => PaymentResultScreen(order: args is OrderModel ? args : OrderModel.fromJson(args is Map ? Map<String, dynamic>.from(args) : const {})), settings: settings);
      case orders: return MaterialPageRoute(builder: (_) => const OrdersScreen(), settings: settings);
      case orderDetail: return MaterialPageRoute(builder: (_) => OrderDetailScreen(orderId: args is int ? args : int.tryParse(args?.toString() ?? '') ?? 0), settings: settings);
      case favorites: return MaterialPageRoute(builder: (_) => const FavoritesScreen(), settings: settings);
      case profile: return MaterialPageRoute(builder: (_) => const ProfileScreen(), settings: settings);
      default: return MaterialPageRoute(builder: (_) => const HomeScreen(), settings: settings);
    }
  }
}
