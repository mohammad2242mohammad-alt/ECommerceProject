import 'package:flutter/material.dart';

import '../../../data/models/address_model.dart';
import '../../../shared/widgets/store_widgets.dart';

class AddressListItem extends StatelessWidget {
  const AddressListItem({super.key, required this.address, required this.selectMode, required this.onSelect, required this.onEdit, required this.onDelete});
  final AddressModel address;
  final bool selectMode;
  final VoidCallback? onSelect;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Card(child: InkWell(onTap: selectMode ? onSelect : null, child: ListTile(
      isThreeLine: true,
      leading: Icon(address.isDefault ? Icons.radio_button_checked : Icons.location_on_outlined, color: address.isDefault ? Theme.of(context).colorScheme.primary : null),
      title: Row(children: [Expanded(child: Text(address.title, style: const TextStyle(fontWeight: FontWeight.bold))), if (address.isDefault) const Padding(padding: EdgeInsets.only(right: 8), child: StatusChip(label: 'پیش‌فرض'))]),
      subtitle: Text('${address.receiverName} - ${address.receiverPhone}\n${address.province}، ${address.city}، ${address.address}\nکدپستی: ${address.postalCode}'),
      trailing: selectMode ? const Icon(Icons.chevron_left) : PopupMenuButton<String>(onSelected: (value) { if (value == 'edit') onEdit(); if (value == 'delete') onDelete(); }, itemBuilder: (_) => const [PopupMenuItem(value: 'edit', child: Text('ویرایش')), PopupMenuItem(value: 'delete', child: Text('حذف'))]),
    )));
  }
}

class AddressFormSheet extends StatelessWidget {
  const AddressFormSheet({super.key, required this.initial, required this.formKey, required this.fields, required this.isDefault, required this.busy, required this.onDefaultChanged, required this.onSave});
  final AddressModel? initial;
  final GlobalKey<FormState> formKey;
  final Map<String, TextEditingController> fields;
  final bool isDefault;
  final bool busy;
  final ValueChanged<bool?> onDefaultChanged;
  final VoidCallback onSave;

  String label(String key) => const {'title':'عنوان (خانه، محل کار...)','receiver_name':'نام گیرنده','receiver_phone':'شماره گیرنده','province':'استان','city':'شهر','address':'نشانی کامل','postal_code':'کدپستی'}[key] ?? key;

  @override
  Widget build(BuildContext context) {
    return Padding(padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom), child: SafeArea(child: SingleChildScrollView(padding: const EdgeInsets.all(18), child: Form(key: formKey, child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      Text(initial == null ? 'افزودن آدرس' : 'ویرایش آدرس', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
      const SizedBox(height: 14),
      ...fields.entries.map((entry) => Padding(padding: const EdgeInsets.only(bottom: 10), child: TextFormField(controller: entry.value, validator: (value) => value == null || value.trim().isEmpty ? 'این فیلد الزامی است' : null, maxLines: entry.key == 'address' ? 3 : 1, keyboardType: entry.key == 'receiver_phone' || entry.key == 'postal_code' ? TextInputType.phone : TextInputType.text, decoration: InputDecoration(labelText: label(entry.key)))),
      CheckboxListTile(value: isDefault, onChanged: onDefaultChanged, title: const Text('آدرس پیش‌فرض باشد'), contentPadding: EdgeInsets.zero),
      FilledButton(onPressed: busy ? null : onSave, child: busy ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)) : const Text('ذخیره آدرس')),
    ]))));
  }
}
