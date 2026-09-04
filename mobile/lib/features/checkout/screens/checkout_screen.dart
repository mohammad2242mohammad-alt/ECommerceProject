import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/routes/app_routes.dart';
import '../../../data/models/address_model.dart';
import '../../../data/repositories/store_repository.dart';
import '../../../providers/store_providers.dart';
import '../../../shared/widgets/store_widgets.dart';

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
    try { summary = await ref.read(storeRepositoryProvider).calculateCheckout(couponCode: coupon.text); setState(() {}); } catch (error) { if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error.toString()))); } finally { if (mounted) setState(() => busy = false); }
  }

  Future<void> _createOrder() async {
    if (selected == null) { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('یک آدرس انتخاب کنید'))); return; }
    setState(() => busy = true);
    try {
      final repo = ref.read(storeRepositoryProvider);
      final order = await repo.createOrder(selected!.id, couponCode: coupon.text);
      final paid = await repo.startPayment(order.id);
      ref.invalidate(cartProvider); ref.invalidate(ordersProvider);
      if (mounted) Navigator.pushReplacementNamed(context, AppRoutes.paymentResult, arguments: paid);
    } catch (error) { if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error.toString()))); } finally { if (mounted) setState(() => busy = false); }
  }

  @override
  Widget build(BuildContext context) {
    final addresses = ref.watch(addressesProvider);
    return Scaffold(appBar: AppBar(title: const Text('تسویه حساب')), body: addresses.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Center(child: Text(error.toString())),
      data: (items) {
        if (selected == null) {
          final defaults = items.where((item) => item.isDefault).toList();
          selected = defaults.isNotEmpty ? defaults.first : (items.isEmpty ? null : items.first);
        }
        if (items.isEmpty) return Center(child: Column(mainAxisSize: MainAxisSize.min, children: [const Icon(Icons.location_off_outlined, size: 56, color: Colors.grey), const SizedBox(height: 12), const Text('برای ثبت سفارش ابتدا آدرس بسازید'), const SizedBox(height: 12), FilledButton.icon(onPressed: () async { await Navigator.pushNamed(context, AppRoutes.addresses); ref.invalidate(addressesProvider); }, icon: const Icon(Icons.add), label: const Text('افزودن آدرس'))]));
        return ListView(padding: const EdgeInsets.all(14), children: [
          const Text('آدرس ارسال', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)), const SizedBox(height: 8),
          ...items.map((address) => Card(child: RadioListTile<AddressModel>(value: address, groupValue: selected, onChanged: (value) => setState(() => selected = value), title: Text(address.title), subtitle: Text('${address.receiverName}\n${address.province}، ${address.city}، ${address.address}')))),
          Align(alignment: Alignment.centerLeft, child: TextButton.icon(onPressed: () async { await Navigator.pushNamed(context, AppRoutes.addresses); ref.invalidate(addressesProvider); }, icon: const Icon(Icons.edit_location_alt_outlined), label: const Text('مدیریت آدرس‌ها'))),
          const Divider(height: 30),
          const Text('کد تخفیف', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)), const SizedBox(height: 8),
          Row(children: [Expanded(child: TextField(controller: coupon, textCapitalization: TextCapitalization.characters, decoration: const InputDecoration(hintText: 'مثلاً WELCOME10'))), const SizedBox(width: 8), OutlinedButton(onPressed: busy ? null : _calculate, child: const Text('اعمال'))]),
          const SizedBox(height: 18),
          if (summary != null) _Summary(summary: summary!),
          const SizedBox(height: 18),
          FilledButton(onPressed: busy ? null : _createOrder, child: busy ? const CircularProgressIndicator() : const Text('ثبت سفارش و پرداخت')), const SizedBox(height: 12),
          const Text('قیمت، تخفیف، هزینه ارسال و مبلغ نهایی توسط بک‌اند محاسبه می‌شود.', textAlign: TextAlign.center, style: TextStyle(color: Colors.grey, fontSize: 12)),
        ]);
      },
    ));
  }
}

class _Summary extends StatelessWidget {
  const _Summary({required this.summary});
  final CheckoutSummary summary;
  @override
  Widget build(BuildContext context) => Card(color: Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(.35), child: Padding(padding: const EdgeInsets.all(16), child: Column(children: [Row(children: [const Text('مجموع کالاها'), const Spacer(), Text('${money(summary.subtotal)} تومان')]), const SizedBox(height: 8), Row(children: [const Text('تخفیف'), const Spacer(), Text('${money(summary.discount)} تومان')]), const SizedBox(height: 8), Row(children: [const Text('هزینه ارسال'), const Spacer(), Text(summary.shipping == 0 ? 'رایگان' : '${money(summary.shipping)} تومان')]), const Divider(height: 24), Row(children: [const Text('مبلغ نهایی', style: TextStyle(fontWeight: FontWeight.bold)), const Spacer(), Text('${money(summary.total)} تومان', style: TextStyle(fontWeight: FontWeight.w900, color: Theme.of(context).colorScheme.primary))])])));
}
