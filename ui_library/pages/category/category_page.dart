import 'package:flutter/material.dart';

import '../../layouts/layout_engine.dart';

/// Configurable Category page. Section ordering is owned by the caller.
class CategoryPage extends StatelessWidget {
  final List<LayoutSection> sections;
  final EdgeInsetsGeometry padding;

  const CategoryPage({
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
