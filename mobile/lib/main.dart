import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/routes/app_routes.dart';
import 'core/theme/app_theme.dart';

void main() => runApp(const ProviderScope(child: EcommerceApp()));

class EcommerceApp extends StatelessWidget {
  const EcommerceApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'فروشگاه اینترنتی',
        theme: AppTheme.lightTheme,
        debugShowCheckedModeBanner: false,
        locale: const Locale('fa'),
        builder: (context, child) => Directionality(textDirection: TextDirection.rtl, child: child ?? const SizedBox.shrink()),
        initialRoute: AppRoutes.home,
        onGenerateRoute: AppRoutes.onGenerateRoute,
      );
}
