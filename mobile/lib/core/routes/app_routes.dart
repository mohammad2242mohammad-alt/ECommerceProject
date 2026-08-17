import 'package:flutter/material.dart';

import '../../features/home/screens/home_screen.dart';

class AppRoutes {

  static const String home = '/';

  static Map<String, WidgetBuilder> routes = {

    home: (context) => const HomeScreen(),

  };

}
