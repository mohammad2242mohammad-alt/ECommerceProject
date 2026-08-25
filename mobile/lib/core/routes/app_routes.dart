import 'package:flutter/material.dart';

import '../../features/home/screens/home_screen.dart';

class AppRoutes {
  AppRoutes._();

  static const String home = '/';

  static Map<String, WidgetBuilder> get routes => {
        home: (context) => const HomeScreen(),
      };
}
