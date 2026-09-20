import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/models/order_model.dart';
import '../../../providers/store_providers.dart';
import '../widgets/order_ui_components.dart';

class OrderDetailScreen extends ConsumerStatefulWidget {
  const OrderDetailScreen({super.key, required this.orderId});
  final int orderId;

  @override
  ConsumerState<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends ConsumerState<OrderDetailScreen> {
  bool busy = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('جزئیات سفارش')),
      body: FutureBuilder<OrderModel>(
        future: ref.read(storeRepositoryProvider).getOrder(widget.orderId),
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text(snapshot.error.toString()));
          }

          final order = snapshot.data!;
          return ListView(
            padding: const EdgeInsets.all(14),
            children: [
              OrderDetailHeaderCard(order: order),
              if (order.addressSnapshot != null)
                OrderAddressCard(address: order.addressSnapshot!),
              const SizedBox(height: 8),
              OrderItemsSection(items: order.items),
              const SizedBox(height: 8),
              OrderTotalsCard(order: order),
              if (order.orderStatus == 'pending' || order.orderStatus == 'confirmed')
                OrderCancelButton(
                  busy: busy,
                  onPressed: () => _cancel(order.id),
                ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _cancel(int id) async {
    setState(() => busy = true);
    try {
      await ref.read(storeRepositoryProvider).cancelOrder(id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('سفارش لغو شد')),
        );
        ref.invalidate(ordersProvider);
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error.toString())),
        );
      }
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }
}
