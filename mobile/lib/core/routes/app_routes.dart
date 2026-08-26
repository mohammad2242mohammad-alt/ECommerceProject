import 'package:flutter/material.dart';

import '../../features/home/screens/home_screen.dart';
import '../../features/products/screens/products_screen.dart';

class AppRoutes {
  AppRoutes._();

  static const String home = '/';
  static const String products = '/products';

  static Map<String, WidgetBuilder> get routes => {
        home: (context) => const HomeScreen(),
        products: (context) => const ProductsScreen(),
      };
}