import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/routes/app_routes.dart';
import '../../../providers/store_providers.dart';
import '../../../shared/widgets/store_widgets.dart';

class OrdersScreen extends ConsumerWidget {
  const OrdersScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (ref.watch(authUserProvider) == null) return Scaffold(appBar: AppBar(title: const Text('سفارش‌ها')), body: const EmptyState(message: 'برای دیدن سفارش‌ها وارد حساب شوید', icon: Icons.lock_outline));
    final orders = ref.watch(ordersProvider);
    return Scaffold(appBar: AppBar(title: const Text('سفارش‌های من')), body: orders.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Center(child: Column(mainAxisSize: MainAxisSize.min, children: [Text(error.toString()), FilledButton(onPressed: () => ref.invalidate(ordersProvider), child: const Text('تلاش مجدد'))])),
      data: (items) => items.isEmpty ? const EmptyState(message: 'هنوز سفارشی ثبت نکرده‌اید', icon: Icons.receipt_long_outlined) : RefreshIndicator(onRefresh: () async => ref.invalidate(ordersProvider), child: ListView.builder(padding: const EdgeInsets.all(12), itemCount: items.length, itemBuilder: (context, index) {
        final order = items[index];
        return Card(child: ListTile(onTap: () => Navigator.pushNamed(context, AppRoutes.orderDetail, arguments: order.id), title: Text(order.orderNumber, style: const TextStyle(fontWeight: FontWeight.bold)), subtitle: Text('${order.items.length} کالا\n${money(order.total)} تومان'), isThreeLine: true, trailing: Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.end, children: [StatusChip(label: orderStatusLabel(order.orderStatus), color: order.orderStatus == 'cancelled' ? Colors.red : Colors.blue), Text(paymentStatusLabel(order.paymentStatus), style: const TextStyle(fontSize: 11))])));
      })),
    ));
  }
}
