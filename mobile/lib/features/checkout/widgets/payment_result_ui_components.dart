import 'package:flutter/material.dart';

import '../../../data/models/order_model.dart';
import '../../../shared/widgets/store_widgets.dart';

class PaymentResultCard extends StatelessWidget {
  const PaymentResultCard({
    super.key,
    required this.order,
    required this.paid,
  });

  final OrderModel order;
  final bool paid;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          paid ? Icons.check_circle_outline : Icons.error_outline,
          size: 90,
          color: paid ? Colors.green : scheme.error,
        ),
        const SizedBox(height: 16),
        Text(
          paid ? 'پرداخت با موفقیت انجام شد' : 'پرداخت ناموفق بود',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 10),
        Text('شماره سفارش: ${order.orderNumber}'),
        const SizedBox(height: 6),
        Text('مبلغ: ${money(order.total)} تومان'),
      ],
    );
  }
}

class PaymentResultActions extends StatelessWidget {
  const PaymentResultActions({
    super.key,
    required this.onViewOrder,
    required this.onBackToStore,
  });

  final VoidCallback onViewOrder;
  final VoidCallback onBackToStore;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        FilledButton(
          onPressed: onViewOrder,
          child: const Text('مشاهده سفارش'),
        ),
        TextButton(
          onPressed: onBackToStore,
          child: const Text('بازگشت به فروشگاه'),
        ),
      ],
    );
  }
}
