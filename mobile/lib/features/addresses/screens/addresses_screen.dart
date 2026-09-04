import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../providers/store_providers.dart';
import '../../../data/models/address_model.dart';
import '../../../shared/widgets/store_widgets.dart';

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
        title: Text(
          selectMode ? 'انتخاب آدرس' : 'آدرس‌های من',
        ),
        actions: [
          IconButton(
            onPressed: () => _showForm(context, ref),
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: addresses.when(
        loading: () =>
            const Center(child: CircularProgressIndicator()),

        error: (error, _) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(error.toString()),
              FilledButton(
                onPressed: () =>
                    ref.invalidate(addressesProvider),
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

              return Card(
                child: InkWell(
                  onTap: selectMode && onSelected != null
                      ? () => onSelected!(address)
                      : null,

                  child: ListTile(
                    isThreeLine: true,

                    leading: Icon(
                      address.isDefault
                          ? Icons.radio_button_checked
                          : Icons.location_on_outlined,
                      color: address.isDefault
                          ? Theme.of(context)
                              .colorScheme
                              .primary
                          : null,
                    ),

                    title: Row(
                      children: [
                        Text(
                          address.title,
                          style:
                              const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        if (address.isDefault)
                          const Padding(
                            padding:
                                EdgeInsets.only(right: 8),
                            child: StatusChip(
                              label: 'پیش‌فرض',
                            ),
                          ),
                      ],
                    ),

                    subtitle: Text(
                      '${address.receiverName} - ${address.receiverPhone}\n'
                      '${address.province}، ${address.city}، ${address.address}\n'
                      'کدپستی: ${address.postalCode}',
                    ),

                    trailing: selectMode
                        ? const Icon(Icons.chevron_left)
                        : PopupMenuButton<String>(
                            onSelected:
                                (value) async {

                              if (value == 'edit') {
                                await _showForm(
                                  context,
                                  ref,
                                  initial: address,
                                );
                              }

                              if (value == 'delete') {
                                await ref
                                    .read(
                                      storeRepositoryProvider,
                                    )
                                    .deleteAddress(
                                      address.id,
                                    );

                                ref.invalidate(
                                  addressesProvider,
                                );
                              }
                            },

                            itemBuilder: (_) => const [
                              PopupMenuItem(
                                value: 'edit',
                                child: Text('ویرایش'),
                              ),

                              PopupMenuItem(
                                value: 'delete',
                                child: Text('حذف'),
                              ),
                            ],
                          ),
                  ),
                ),
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
      builder: (_) =>
          _AddressForm(initial: initial),
    );

    ref.invalidate(addressesProvider);
  }
}



class _AddressForm extends ConsumerStatefulWidget {

  const _AddressForm({
    this.initial,
  });

  final AddressModel? initial;

  @override
  ConsumerState<_AddressForm> createState() =>
      _AddressFormState();
}



class _AddressFormState
    extends ConsumerState<_AddressForm> {

  final key =
      GlobalKey<FormState>();

  late final Map<String, TextEditingController> fields =
      {
        'title': TextEditingController(
            text: widget.initial?.title),

        'receiver_name': TextEditingController(
            text: widget.initial?.receiverName),

        'receiver_phone': TextEditingController(
            text: widget.initial?.receiverPhone),

        'province': TextEditingController(
            text: widget.initial?.province),

        'city': TextEditingController(
            text: widget.initial?.city),

        'address': TextEditingController(
            text: widget.initial?.address),

        'postal_code': TextEditingController(
            text: widget.initial?.postalCode),
      };


  bool isDefault = false;
  bool busy = false;


  @override
  void initState() {
    super.initState();

    isDefault =
        widget.initial?.isDefault ?? false;
  }


  @override
  void dispose() {

    for (final controller in fields.values) {
      controller.dispose();
    }

    super.dispose();
  }


  String? requiredValue(String? value) {

    if (value == null ||
        value.trim().isEmpty) {
      return 'این فیلد الزامی است';
    }

    return null;
  }


  @override
  Widget build(BuildContext context) {

    return Padding(
      padding: EdgeInsets.only(
        bottom:
            MediaQuery.viewInsetsOf(context).bottom,
      ),

      child: SafeArea(

        child: SingleChildScrollView(

          padding:
              const EdgeInsets.all(18),

          child: Form(

            key: key,

            child: Column(

              crossAxisAlignment:
                  CrossAxisAlignment.stretch,

              children: [

                Text(
                  widget.initial == null
                      ? 'افزودن آدرس'
                      : 'ویرایش آدرس',

                  style: Theme.of(context)
                      .textTheme
                      .titleLarge
                      ?.copyWith(
                        fontWeight:
                            FontWeight.bold,
                      ),
                ),


                const SizedBox(height: 14),


                ...fields.entries.map(
                  (entry) {

                    return Padding(
                      padding:
                          const EdgeInsets.only(
                            bottom: 10,
                          ),

                      child: TextFormField(

                        controller:
                            entry.value,

                        validator:
                            requiredValue,

                        maxLines:
                            entry.key == 'address'
                                ? 3
                                : 1,

                        keyboardType:
                            entry.key ==
                                        'receiver_phone' ||
                                    entry.key ==
                                        'postal_code'
                                ? TextInputType.phone
                                : TextInputType.text,

                        decoration:
                            InputDecoration(
                          labelText:
                              _label(entry.key),
                        ),
                      ),
                    );
                  },
                ),


                CheckboxListTile(

                  value:
                      isDefault,

                  onChanged:
                      (value) {

                    setState(() {
                      isDefault =
                          value ?? false;
                    });
                  },

                  title:
                      const Text(
                    'آدرس پیش‌فرض باشد',
                  ),

                  contentPadding:
                      EdgeInsets.zero,
                ),


                FilledButton(

                  onPressed:
                      busy
                          ? null
                          : _save,

                  child:
                      busy
                          ? const CircularProgressIndicator()
                          : const Text(
                              'ذخیره آدرس',
                            ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }



  Future<void> _save() async {

    if (!key.currentState!.validate()) {
      return;
    }


    setState(() {
      busy = true;
    });


    try {

      final body =
          <String, dynamic>{
        for (final entry in fields.entries)
          entry.key:
              entry.value.text.trim(),

        'is_default':
            isDefault,
      };


      await ref
          .read(storeRepositoryProvider)
          .saveAddress(
            body,
            id: widget.initial?.id,
          );


      if (mounted) {
        Navigator.pop(context);
      }


    } catch (error) {

      if (mounted) {

        ScaffoldMessenger.of(context)
            .showSnackBar(
          SnackBar(
            content:
                Text(error.toString()),
          ),
        );
      }

    } finally {

      if (mounted) {

        setState(() {
          busy = false;
        });
      }
    }
  }



  String _label(String key) {

    return const {

      'title':
          'عنوان (خانه، محل کار...)',

      'receiver_name':
          'نام گیرنده',

      'receiver_phone':
          'شماره گیرنده',

      'province':
          'استان',

      'city':
          'شهر',

      'address':
          'نشانی کامل',

      'postal_code':
          'کدپستی',

    }[key] ?? key;
  }
}