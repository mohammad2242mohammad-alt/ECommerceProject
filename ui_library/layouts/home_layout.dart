import 'package:flutter/material.dart';

import 'layout_engine.dart';
import 'layout_registry.dart';

/// Reusable Home layout builder. The caller owns data and navigation; this
/// class only maps a chosen section order to widgets.
class HomeLayout {
  const HomeLayout._();

  static Widget build({
    required BuildContext context,
    required LayoutRegistry registry,
    required List<String> sectionIds,
    EdgeInsetsGeometry padding = EdgeInsets.zero,
  }) {
    return ConfigurableLayout(
      padding: padding,
      sections: registry.buildSections(context, sectionIds),
    );
  }
}
