import 'package:flutter/material.dart';

/// Data model for a reusable shipping address.
class AddressItem {
  final String id;
  final String title;
  final String recipientName;
  final String phone;
  final String address;
  final String? postalCode;
  final bool isDefault;

  const AddressItem({
    required this.id,
    required this.title,
    required this.recipientName,
    required this.phone,
    required this.address,
    this.postalCode,
    this.isDefault = false,
  });
}

/// Reusable address selector/card. Validation, persistence and API calls stay
/// outside the UI library.
class AddressComponent extends StatelessWidget {
  final List<AddressItem> addresses;
  final String? selectedAddressId;
  final ValueChanged<AddressItem>? onSelect;
  final ValueChanged<AddressItem>? onEdit;
  final ValueChanged<AddressItem>? onDelete;
  final VoidCallback? onAddAddress;
  final String title;
  final String? subtitle;
  final bool showAddButton;

  const AddressComponent({
    super.key,
    required this.addresses,
    this.selectedAddressId,
    this.onSelect,
    this.onEdit,
    this.onDelete,
    this.onAddAddress,
    this.title = 'آدرس ارسال',
    this.subtitle,
    this.showAddButton = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(16, 8, 16, 12),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      if (subtitle != null) ...[
                        const SizedBox(height: 3),
                        Text(subtitle!, style: theme.textTheme.bodySmall),
                      ],
                    ],
                  ),
                ),
                if (showAddButton && onAddAddress != null)
                  TextButton.icon(
                    onPressed: onAddAddress,
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text('افزودن'),
                  ),
              ],
            ),
          ),
          if (addresses.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Material(
                color: theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(16),
                child: InkWell(
                  onTap: onAddAddress,
                  borderRadius: BorderRadius.circular(16),
                  child: const Padding(
                    padding: EdgeInsets.all(20),
                    child: Row(
                      children: [
                        Icon(Icons.location_on_outlined),
                        SizedBox(width: 10),
                        Expanded(child: Text('هنوز آدرسی ثبت نشده است.')),
                        Icon(Icons.chevron_left),
                      ],
                    ),
                  ),
                ),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: addresses.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final item = addresses[index];
                final selected = item.id == selectedAddressId;
                return _AddressCard(
                  address: item,
                  selected: selected,
                  onSelect: onSelect == null ? null : () => onSelect!(item),
                  onEdit: onEdit == null ? null : () => onEdit!(item),
                  onDelete: onDelete == null ? null : () => onDelete!(item),
                );
              },
            ),
        ],
      ),
    );
  }
}

class _AddressCard extends StatelessWidget {
  final AddressItem address;
  final bool selected;
  final VoidCallback? onSelect;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const _AddressCard({
    required this.address,
    required this.selected,
    this.onSelect,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final borderColor = selected
        ? theme.colorScheme.primary
        : theme.colorScheme.outlineVariant;

    return Material(
      color: theme.colorScheme.surface,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onSelect,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: borderColor,
              width: selected ? 2 : 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    selected
                        ? Icons.radio_button_checked
                        : Icons.radio_button_off,
                    color: selected
                        ? theme.colorScheme.primary
                        : theme.colorScheme.outline,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      address.title,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  if (address.isDefault)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        'پیش‌فرض',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.onPrimaryContainer,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                address.recipientName,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              Text(address.phone, style: theme.textTheme.bodySmall),
              const SizedBox(height: 8),
              Text(address.address, style: theme.textTheme.bodyMedium),
              if (address.postalCode != null) ...[
                const SizedBox(height: 5),
                Text(
                  'کد پستی: ${address.postalCode}',
                  style: theme.textTheme.bodySmall,
                ),
              ],
              if (onEdit != null || onDelete != null) ...[
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (onEdit != null)
                      TextButton.icon(
                        onPressed: onEdit,
                        icon: const Icon(Icons.edit_outlined, size: 17),
                        label: const Text('ویرایش'),
                      ),
                    if (onDelete != null)
                      TextButton.icon(
                        onPressed: onDelete,
                        icon: const Icon(Icons.delete_outline, size: 17),
                        label: const Text('حذف'),
                      ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
