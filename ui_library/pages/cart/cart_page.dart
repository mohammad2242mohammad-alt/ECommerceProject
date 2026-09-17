import 'package:flutter/material.dart';

import '../../layouts/layout_engine.dart';

/// Configurable Cart page. Cart state and checkout rules stay outside.
class CartPage extends StatelessWidget {
  final List<LayoutSection> sections;
  final EdgeInsetsGeometry padding;

  const CartPage({
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
