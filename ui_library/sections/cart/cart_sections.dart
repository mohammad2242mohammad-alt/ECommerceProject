import 'package:flutter/material.dart';

import '../../components/cart/cart.dart';

/// Reusable Cart sections. Cart state and backend calculations stay outside.
class CartSections {
  const CartSections._();

  static Widget items({
    required List<CartItem> items,
    ValueChanged<CartItem>? onItemTap,
    ValueChanged<CartItem>? onIncrease,
    ValueChanged<CartItem>? onDecrease,
    ValueChanged<CartItem>? onRemove,
    String title = 'سبد خرید',
  }) {
    return CartComponent(
      items: items,
      title: title,
      onItemTap: onItemTap,
      onIncrease: onIncrease,
      onDecrease: onDecrease,
      onRemove: onRemove,
      showSummary: false,
      showCheckout: false,
    );
  }

  static Widget summary({required Widget content}) => _Section(child: content);

  static Widget checkout({
    required VoidCallback? onCheckout,
    String label = 'ادامه و ثبت سفارش',
  }) {
    return CartComponent(
      items: const [],
      showSummary: true,
      showCheckout: true,
      checkoutLabel: label,
      onCheckout: onCheckout,
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
