import 'package:flutter/material.dart';

import '../../../data/models/order_model.dart';
import '../../../shared/widgets/store_widgets.dart';

class OrdersLoginRequired extends StatelessWidget {
  const OrdersLoginRequired({super.key, required this.onLogin});
  final VoidCallback onLogin;
  @override
  Widget build(BuildContext context) => EmptyState(message: 'برای دیدن سفارش‌ها وارد حساب شوید', icon: Icons.lock_outline);
}

class OrderListCard extends StatelessWidget {
  const OrderListCard({super.key, required this.order, required this.onTap});
  final OrderModel order;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    final cancelled = order.orderStatus == 'cancelled';
    return Card(child: ListTile(
      onTap: onTap,
      title: Text(order.orderNumber, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text('\${order.items.length} کالا\\n\${money(order.total)} تومان'),
      isThreeLine: true,
      trailing: Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.end, children: [
        StatusChip(label: orderStatusLabel(order.orderStatus), color: cancelled ? Colors.red : Colors.blue),
        Text(paymentStatusLabel(order.paymentStatus), style: const TextStyle(fontSize: 11)),
      ]),
    ));
  }
}

class OrderDetailHeaderCard extends StatelessWidget {
  const OrderDetailHeaderCard({super.key, required this.order});
  final OrderModel order;
  @override
  Widget build(BuildContext context) => Card(child: Padding(
    padding: const EdgeInsets.all(16),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(order.orderNumber, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
      const SizedBox(height: 12),
      Wrap(spacing: 8, runSpacing: 8, children: [
        StatusChip(label: orderStatusLabel(order.orderStatus), color: order.orderStatus == 'cancelled' ? Colors.red : Colors.blue),
        StatusChip(label: paymentStatusLabel(order.paymentStatus), color: order.paymentStatus == 'paid' ? Colors.green : Colors.orange),
      ]),
    ]),
  ));
}

class OrderAddressCard extends StatelessWidget {
  const OrderAddressCard({super.key, required this.address});
  final Map<String, dynamic> address;
  @override
  Widget build(BuildContext context) => Card(child: ListTile(
    leading: const Icon(Icons.location_on_outlined),
    title: Text(address['title']?.toString() ?? 'آدرس ارسال'),
    subtitle: Text('\${address['receiver_name'] ?? ''}\\n\${address['province'] ?? ''}، \${address['city'] ?? ''}، \${address['address'] ?? ''}'),
  ));
}

class OrderItemsSection extends StatelessWidget {
  const OrderItemsSection({super.key, required this.items});
  final List<OrderItemModel> items;
  @override
  Widget build(BuildContext context) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    const Text('اقلام سفارش', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
    const SizedBox(height: 8),
    ...items.map((item) => Card(child: ListTile(
      title: Text(item.productName),
      subtitle: Text('\${item.quantity} عدد × \${money(item.unitPrice)} تومان'),
      trailing: Text('\${money(item.lineTotal)} تومان'),
    ))),
  ]);
}

class OrderTotalsCard extends StatelessWidget {
  const OrderTotalsCard({super.key, required this.order});
  final OrderModel order;
  @override
  Widget build(BuildContext context) => Card(child: Padding(
    padding: const EdgeInsets.all(16),
    child: Column(children: [
      _Row(label: 'جمع کالاها', value: '\${money(order.subtotal)} تومان'),
      _Row(label: 'تخفیف', value: '\${money(order.discountTotal)} تومان'),
      _Row(label: 'ارسال', value: '\${money(order.shippingTotal)} تومان'),
      const Divider(),
      _Row(label: 'مبلغ نهایی', value: '\${money(order.total)} تومان', bold: true),
    ]),
  ));
}

class _Row extends StatelessWidget {
  const _Row({required this.label, required this.value, this.bold = false});
  final String label;
  final String value;
  final bool bold;
  @override
  Widget build(BuildContext context) {
    final style = bold ? const TextStyle(fontWeight: FontWeight.bold) : null;
    return Padding(padding: const EdgeInsets.symmetric(vertical: 3), child: Row(children: [
      Text(label, style: style), const Spacer(), Text(value, style: style),
    ]));
  }
}

class OrderCancelButton extends StatelessWidget {
  const OrderCancelButton({super.key, required this.onPressed, required this.busy});
  final VoidCallback? onPressed;
  final bool busy;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: 12),
    child: OutlinedButton.icon(onPressed: busy ? null : onPressed, icon: const Icon(Icons.cancel_outlined), label: Text(busy ? 'در حال لغو...' : 'لغو سفارش')),
  );
}
