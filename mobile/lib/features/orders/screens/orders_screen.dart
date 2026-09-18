import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/routes/app_routes.dart';
import '../../../providers/store_providers.dart';
import '../../../shared/widgets/shared_widgets.dart';
import '../widgets/order_ui_components.dart';

class OrdersScreen extends ConsumerWidget {
  const OrdersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (ref.watch(authUserProvider) == null) {
      return const Scaffold(
        appBar: AppBar(title: Text('سفارش‌ها')),
        body: OrdersLoginRequired(onLogin: _noop),
      );
    }

    final orders = ref.watch(ordersProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('سفارش‌های من')),
      body: orders.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(error.toString()),
              FilledButton(
                onPressed: () => ref.invalidate(ordersProvider),
                child: const Text('تلاش مجدد'),
              ),
            ],
          ),
        ),
        data: (items) => items.isEmpty
            ? const EmptyState(
                message: 'هنوز سفارشی ثبت نکرده‌اید',
                icon: Icons.receipt_long_outlined,
              )
            : RefreshIndicator(
                onRefresh: () async => ref.invalidate(ordersProvider),
                child: ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final order = items[index];
                    return OrderListCard(
                      order: order,
                      onTap: () => Navigator.pushNamed(
                        context,
                        AppRoutes.orderDetail,
                        arguments: order.id,
                      ),
                    );
                  },
                ),
              ),
      ),
    );
  }

  static void _noop() {}
}
