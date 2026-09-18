import 'package:flutter/material.dart';

import '../../layouts/layout_engine.dart';

/// Configurable Orders page. Order state and filtering stay outside.
class OrdersPage extends StatelessWidget {
  final List<LayoutSection> sections;
  final EdgeInsetsGeometry padding;

  const OrdersPage({
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
