import 'package:flutter/material.dart';

import '../../../data/models/address_model.dart';
import '../../../data/repositories/store_repository.dart';

class CheckoutAddressSection extends StatelessWidget {
  const CheckoutAddressSection({super.key, required this.items, required this.selected, required this.onChanged, required this.onManage});
  final List<AddressModel> items;
  final AddressModel? selected;
  final ValueChanged<AddressModel?> onChanged;
  final VoidCallback onManage;
  @override
  Widget build(BuildContext context) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    const Text('آدرس ارسال', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
    const SizedBox(height: 8),
    ...items.map((address) => Card(child: RadioListTile<AddressModel>(value: address, groupValue: selected, onChanged: onChanged, title: Text(address.title), subtitle: Text('${address.receiverName}\n${address.province}، ${address.city}، ${address.address}')))),
    Align(alignment: Alignment.centerLeft, child: TextButton.icon(onPressed: onManage, icon: const Icon(Icons.edit_location_alt_outlined), label: const Text('مدیریت آدرس‌ها'))),
  ]);
}

class CheckoutNoAddressState extends StatelessWidget {
  const CheckoutNoAddressState({super.key, required this.onAddAddress});
  final VoidCallback onAddAddress;
  @override
  Widget build(BuildContext context) => Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
    const Icon(Icons.location_off_outlined, size: 56, color: Colors.grey), const SizedBox(height: 12),
    const Text('برای ثبت سفارش ابتدا آدرس بسازید'), const SizedBox(height: 12),
    FilledButton.icon(onPressed: onAddAddress, icon: const Icon(Icons.add), label: const Text('افزودن آدرس')),
  ]));
}

class CheckoutCouponSection extends StatelessWidget {
  const CheckoutCouponSection({super.key, required this.controller, required this.onApply, required this.busy});
  final TextEditingController controller;
  final VoidCallback onApply;
  final bool busy;
  @override
  Widget build(BuildContext context) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    const Text('کد تخفیف', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)), const SizedBox(height: 8),
    Row(children: [Expanded(child: TextField(controller: controller, textCapitalization: TextCapitalization.characters, decoration: const InputDecoration(hintText: 'مثلاً WELCOME10'))), const SizedBox(width: 8), OutlinedButton(onPressed: busy ? null : onApply, child: const Text('اعمال'))]),
  ]);
}

class CheckoutSummaryCard extends StatelessWidget {
  const CheckoutSummaryCard({super.key, required this.summary});
  final CheckoutSummary summary;
  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Card(color: scheme.surfaceContainerHighest.withValues(alpha: .35), child: Padding(padding: const EdgeInsets.all(16), child: Column(children: [
      _row('مجموع کالاها', '${money(summary.subtotal)} تومان'), const SizedBox(height: 8),
      _row('تخفیف', '${money(summary.discount)} تومان'), const SizedBox(height: 8),
      _row('هزینه ارسال', summary.shipping == 0 ? 'رایگان' : '${money(summary.shipping)} تومان'),
      const Divider(height: 24), _row('مبلغ نهایی', '${money(summary.total)} تومان', bold: true, valueColor: scheme.primary),
    ])));
  }
  Widget _row(String title, String value, {bool bold = false, Color? valueColor}) => Row(children: [Text(title, style: TextStyle(fontWeight: bold ? FontWeight.bold : null)), const Spacer(), Text(value, style: TextStyle(fontWeight: bold ? FontWeight.w900 : null, color: valueColor))]);
}

class CheckoutSubmitSection extends StatelessWidget {
  const CheckoutSubmitSection({super.key, required this.busy, required this.onSubmit});
  final bool busy;
  final VoidCallback onSubmit;
  @override
  Widget build(BuildContext context) => Column(children: [
    FilledButton(onPressed: busy ? null : onSubmit, child: busy ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)) : const Text('ثبت سفارش و پرداخت')),
    const SizedBox(height: 12),
    const Text('قیمت، تخفیف، هزینه ارسال و مبلغ نهایی توسط بک‌اند محاسبه می‌شود.', textAlign: TextAlign.center, style: TextStyle(color: Colors.grey, fontSize: 12)),
  ]);
}
