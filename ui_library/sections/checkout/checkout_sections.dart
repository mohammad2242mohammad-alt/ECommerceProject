import 'package:flutter/material.dart';

import '../../components/checkout/checkout.dart';

/// Reusable Checkout sections. Backend-owned totals and payment state are
/// supplied by the page/controller and are never calculated here.
class CheckoutSections {
  const CheckoutSections._();

  static Widget address({required Widget content}) => _Section(child: content);

  static Widget shipping({required Widget content}) => _Section(child: content);

  static Widget payment({required Widget content}) => _Section(child: content);

  static Widget summary({
    required CheckoutSummary summary,
    required VoidCallback? onConfirm,
    bool isLoading = false,
    bool enabled = true,
    String confirmLabel = 'ثبت سفارش و پرداخت',
  }) {
    return CheckoutComponent(
      summary: summary,
      onConfirm: onConfirm,
      isLoading: isLoading,
      enabled: enabled,
      confirmLabel: confirmLabel,
    );
  }
}

class _Section extends StatelessWidget {
  final Widget child;

  const _Section({required this.child});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: child,
    );
  }
}
