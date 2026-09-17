import 'package:flutter/material.dart';

/// Data model for a reusable shipping method.
class ShippingMethodItem {
  final String id;
  final String title;
  final String description;
  final String priceLabel;
  final String? deliveryLabel;
  final IconData icon;
  final bool isAvailable;

  const ShippingMethodItem({
    required this.id,
    required this.title,
    required this.description,
    required this.priceLabel,
    this.deliveryLabel,
    this.icon = Icons.local_shipping_outlined,
    this.isAvailable = true,
  });
}

/// Reusable shipping-method selector. Shipping rules and final pricing stay
/// outside the component and are controlled by the checkout layer.
class ShippingComponent extends StatelessWidget {
  final List<ShippingMethodItem> methods;
  final String? selectedMethodId;
  final ValueChanged<ShippingMethodItem>? onSelect;
  final String title;
  final String? subtitle;
  final bool showPrice;

  const ShippingComponent({
    super.key,
    required this.methods,
    this.selectedMethodId,
    this.onSelect,
    this.title = 'روش ارسال',
    this.subtitle,
    this.showPrice = true,
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
          if (methods.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: _EmptyShippingState(),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: methods.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final method = methods[index];
                return _ShippingMethodCard(
                  method: method,
                  selected: method.id == selectedMethodId,
                  onSelect: method.isAvailable && onSelect != null
                      ? () => onSelect!(method)
                      : null,
                  showPrice: showPrice,
                );
              },
            ),
        ],
      ),
    );
  }
}

class _ShippingMethodCard extends StatelessWidget {
  final ShippingMethodItem method;
  final bool selected;
  final VoidCallback? onSelect;
  final bool showPrice;

  const _ShippingMethodCard({
    required this.method,
    required this.selected,
    required this.onSelect,
    required this.showPrice,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final borderColor = selected
        ? theme.colorScheme.primary
        : theme.colorScheme.outlineVariant;

    return Material(
      color: method.isAvailable
          ? theme.colorScheme.surface
          : theme.colorScheme.surfaceContainerHighest,
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
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                selected
                    ? Icons.radio_button_checked
                    : Icons.radio_button_off,
                color: method.isAvailable
                    ? (selected
                        ? theme.colorScheme.primary
                        : theme.colorScheme.outline)
                    : theme.colorScheme.outline,
              ),
              const SizedBox(width: 10),
              CircleAvatar(
                radius: 22,
                backgroundColor: theme.colorScheme.primaryContainer,
                child: Icon(
                  method.icon,
                  color: theme.colorScheme.onPrimaryContainer,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            method.title,
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                        if (showPrice)
                          Text(
                            method.priceLabel,
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 5),
                    Text(
                      method.description,
                      style: theme.textTheme.bodySmall,
                    ),
                    if (method.deliveryLabel != null) ...[
                      const SizedBox(height: 6),
                      Text(
                        method.deliveryLabel!,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                    if (!method.isAvailable) ...[
                      const SizedBox(height: 6),
                      Text(
                        'در حال حاضر در دسترس نیست',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.error,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyShippingState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Row(
        children: [
          Icon(Icons.local_shipping_outlined),
          SizedBox(width: 10),
          Expanded(child: Text('روش ارسالی برای این سفارش موجود نیست.')),
        ],
      ),
    );
  }
}
