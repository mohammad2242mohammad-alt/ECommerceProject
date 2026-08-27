import 'package:flutter/material.dart';

import '../../features/home/screens/home_screen.dart';
import '../../features/products/screens/products_screen.dart';

class AppRoutes {
  AppRoutes._();

  static const String home = '/';
  static const String products = '/products';

  static Map<String, WidgetBuilder> get routes => {
        home: (context) => const HomeScreen(),
      };

  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    final uri = Uri.tryParse(settings.name ?? '');

    if (uri?.path == products) {
      final queryCategoryId = int.tryParse(
        uri?.queryParameters['category_id'] ?? '',
      );

      final argumentCategoryId = settings.arguments is int
          ? settings.arguments as int
          : null;

      return MaterialPageRoute(
        builder: (_) => ProductsScreen(
          categoryId: queryCategoryId ?? argumentCategoryId,
        ),
        settings: settings,
      );
    }

    return MaterialPageRoute(
      builder: (_) => const HomeScreen(),
      settings: settings,
    );
  }
}
