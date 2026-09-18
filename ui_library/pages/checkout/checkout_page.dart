import 'package:flutter/material.dart';

import '../../layouts/layout_engine.dart';

/// Configurable Checkout page. Totals, payment state and validation stay outside.
class CheckoutPage extends StatelessWidget {
  final List<LayoutSection> sections;
  final EdgeInsetsGeometry padding;

  const CheckoutPage({
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
