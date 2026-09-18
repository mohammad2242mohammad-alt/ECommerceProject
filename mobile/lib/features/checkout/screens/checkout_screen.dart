import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/routes/app_routes.dart';
import '../../../data/models/address_model.dart';
import '../../../providers/store_providers.dart';
import '../widgets/checkout_ui_components.dart';

class CheckoutScreen extends ConsumerStatefulWidget {
  const CheckoutScreen({super.key});
  @override
  ConsumerState<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends ConsumerState<CheckoutScreen> {
  AddressModel? selected;
  final coupon = TextEditingController();
  CheckoutSummary? summary;
  bool busy = false;

  @override
  void dispose() { coupon.dispose(); super.dispose(); }

  Future<void> _calculate() async {
    setState(() => busy = true);
    try {
      summary = await ref.read(storeRepositoryProvider).calculateCheckout(couponCode: coupon.text);
      setState(() {});
    } catch (error) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error.toString())));
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  Future<void> _createOrder() async {
    if (selected == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('یک آدرس انتخاب کنید')));
      return;
    }
    setState(() => busy = true);
    try {
      final repo = ref.read(storeRepositoryProvider);
      final order = await repo.createOrder(selected!.id, couponCode: coupon.text);
      final paid = await repo.startPayment(order.id);
      ref.invalidate(cartProvider);
      ref.invalidate(ordersProvider);
      if (mounted) Navigator.pushReplacementNamed(context, AppRoutes.paymentResult, arguments: paid);
    } catch (error) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error.toString())));
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  Future<void> _manageAddresses() async {
    await Navigator.pushNamed(context, AppRoutes.addresses);
    ref.invalidate(addressesProvider);
  }

  @override
  Widget build(BuildContext context) {
    final addresses = ref.watch(addressesProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('تسویه حساب')),
      body: addresses.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text(error.toString())),
        data: (items) {
          if (selected == null) {
            final defaults = items.where((item) => item.isDefault).toList();
            selected = defaults.isNotEmpty ? defaults.first : (items.isEmpty ? null : items.first);
          }
          if (items.isEmpty) {
            return CheckoutNoAddressState(onAddAddress: _manageAddresses);
          }
          return ListView(
            padding: const EdgeInsets.all(14),
            children: [
              CheckoutAddressSection(items: items, selected: selected, onChanged: (value) => setState(() => selected = value), onManage: _manageAddresses),
              const Divider(height: 30),
              CheckoutCouponSection(controller: coupon, onApply: _calculate, busy: busy),
              const SizedBox(height: 18),
              if (summary != null) CheckoutSummaryCard(summary: summary!),
              const SizedBox(height: 18),
              CheckoutSubmitSection(busy: busy, onSubmit: _createOrder),
            ],
          );
        },
      ),
    );
  }
}
