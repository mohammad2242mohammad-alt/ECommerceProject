import 'package:flutter/material.dart';

import '../../layouts/layout_engine.dart';

/// Configurable Product Detail page. Product state and actions stay outside.
class ProductDetailPage extends StatelessWidget {
  final List<LayoutSection> sections;
  final EdgeInsetsGeometry padding;

  const ProductDetailPage({
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
