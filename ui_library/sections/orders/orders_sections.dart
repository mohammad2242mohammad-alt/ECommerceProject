import 'package:flutter/material.dart';

import '../../components/order/order.dart';

/// Reusable Orders sections. Loading, filtering and navigation stay outside.
class OrdersSections {
  const OrdersSections._();

  static Widget header({required Widget content}) => _Section(child: content);

  static Widget list({
    required List<OrderItem> orders,
    ValueChanged<OrderItem>? onOrderTap,
    String title = 'سفارش‌های من',
  }) {
    return OrderComponent(
      orders: orders,
      title: title,
      onOrderTap: onOrderTap,
    );
  }

  static Widget filters({required Widget content}) => _Section(child: content);

  static Widget auxiliary({required Widget content}) => _Section(child: content);
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
