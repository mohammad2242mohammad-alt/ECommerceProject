import 'dart:convert';

import 'package:flutter/services.dart';

/// Loads ordered section ids from JSON layout configs shipped with the UI library.
/// The page remains responsible for providing actual widgets and business logic.
class LayoutConfigLoader {
  const LayoutConfigLoader._();

  static Future<List<String>> load(String configName) async {
    final path = 'packages/ecommerce_ui_library/layout_configs/$configName.json';
    final raw = await rootBundle.loadString(path);
    final decoded = jsonDecode(raw);

    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('Invalid layout config root.');
    }

    final sections = decoded['sections'];
    if (sections is! List) {
      throw const FormatException('Layout config must contain a sections array.');
    }

    return sections.whereType<String>().toList(growable: false);
  }
}
