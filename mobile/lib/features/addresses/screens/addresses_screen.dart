import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/models/address_model.dart';
import '../../../providers/store_providers.dart';
import '../../../shared/widgets/shared_widgets.dart';
import '../widgets/address_ui_components.dart';

class AddressesScreen extends ConsumerWidget {
  const AddressesScreen({
    super.key,
    this.selectMode = false,
    this.onSelected,
  });

  final bool selectMode;
  final ValueChanged<AddressModel>? onSelected;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final addresses = ref.watch(addressesProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(selectMode ? 'انتخاب آدرس' : 'آدرس‌های من'),
        actions: [
          IconButton(
            onPressed: () => _showForm(context, ref),
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: addresses.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(error.toString()),
              FilledButton(
                onPressed: () => ref.invalidate(addressesProvider),
                child: const Text('تلاش مجدد'),
              ),
            ],
          ),
        ),
        data: (items) {
          if (items.isEmpty) {
            return const EmptyState(
              message: 'هنوز آدرسی ثبت نکرده‌اید',
              icon: Icons.location_on_outlined,
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: items.length,
            itemBuilder: (context, index) {
              final address = items[index];
              return AddressListItem(
                address: address,
                selectMode: selectMode,
                onSelect: selectMode && onSelected != null
                    ? () => onSelected!(address)
                    : null,
                onEdit: () => _showForm(
                  context,
                  ref,
                  initial: address,
                ),
                onDelete: () async {
                  await ref
                      .read(storeRepositoryProvider)
                      .deleteAddress(address.id);
                  ref.invalidate(addressesProvider);
                },
              );
            },
          );
        },
      ),
    );
  }

  Future<void> _showForm(
    BuildContext context,
    WidgetRef ref, {
    AddressModel? initial,
  }) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (_) => _AddressForm(initial: initial),
    );
    ref.invalidate(addressesProvider);
  }
}

class _AddressForm extends ConsumerStatefulWidget {
  const _AddressForm({this.initial});

  final AddressModel? initial;

  @override
  ConsumerState<_AddressForm> createState() => _AddressFormState();
}

class _AddressFormState extends ConsumerState<_AddressForm> {
  final key = GlobalKey<FormState>();

  late final Map<String, TextEditingController> fields = {
    'title': TextEditingController(text: widget.initial?.title),
    'receiver_name':
        TextEditingController(text: widget.initial?.receiverName),
    'receiver_phone':
        TextEditingController(text: widget.initial?.receiverPhone),
    'province': TextEditingController(text: widget.initial?.province),
    'city': TextEditingController(text: widget.initial?.city),
    'address': TextEditingController(text: widget.initial?.address),
    'postal_code':
        TextEditingController(text: widget.initial?.postalCode),
  };

  bool isDefault = false;
  bool busy = false;

  @override
  void initState() {
    super.initState();
    isDefault = widget.initial?.isDefault ?? false;
  }

  @override
  void dispose() {
    for (final controller in fields.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AddressFormSheet(
      initial: widget.initial,
      formKey: key,
      fields: fields,
      isDefault: isDefault,
      busy: busy,
      onDefaultChanged: (value) {
        setState(() => isDefault = value ?? false);
      },
      onSave: _save,
    );
  }

  Future<void> _save() async {
    if (!key.currentState!.validate()) return;

    setState(() => busy = true);

    try {
      final body = <String, dynamic>{
        for (final entry in fields.entries)
          entry.key: entry.value.text.trim(),
        'is_default': isDefault,
      };

      await ref
          .read(storeRepositoryProvider)
          .saveAddress(
            body,
            id: widget.initial?.id,
          );

      if (mounted) Navigator.pop(context);
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
