import 'package:flutter/material.dart';

import '../../layouts/layout_engine.dart';

/// Configurable Home page. Pass sections in the desired visual order.
class HomePage extends StatelessWidget {
  final List<LayoutSection> sections;
  final EdgeInsetsGeometry padding;

  const HomePage({
    super.key,
    required this.sections,
    this.padding = EdgeInsets.zero,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ConfigurableLayout(
        sections: sections,
        padding: padding,
      ),
    );
  }
}
