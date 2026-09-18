import 'package:flutter/material.dart';

/// Data model for one reusable cart line.
class CartItem {
  final String id;
  final String title;
  final String? imageUrl;
  final int price;
  final int quantity;
  final int? oldPrice;
  final bool isAvailable;

  const CartItem({
    required this.id,
    required this.title,
    required this.price,
    required this.quantity,
    this.imageUrl,
    this.oldPrice,
    this.isAvailable = true,
  });

  int get lineTotal => price * quantity;
}

/// Reusable cart section. Cart rules, stock validation and persistence stay
/// outside the UI library.
class CartComponent extends StatelessWidget {
  final List<CartItem> items;
  final ValueChanged<CartItem>? onItemTap;
  final ValueChanged<CartItem>? onIncrease;
  final ValueChanged<CartItem>? onDecrease;
  final ValueChanged<CartItem>? onRemove;
  final VoidCallback? onCheckout;
  final String title;
  final String currencyLabel;
  final String checkoutLabel;
  final bool showSummary;
  final bool showCheckout;

  const CartComponent({
    super.key,
    required this.items,
    this.onItemTap,
    this.onIncrease,
    this.onDecrease,
    this.onRemove,
    this.onCheckout,
    this.title = 'سبد خرید',
    this.currencyLabel = 'تومان',
    this.checkoutLabel = 'ادامه و پرداخت',
    this.showSummary = true,
    this.showCheckout = true,
  });

  String _money(int value) => '${value.toString()} $currencyLabel';

  @override
  Widget build(BuildContext context) {
    final total = items.fold<int>(0, (sum, item) => sum + item.lineTotal);
    final theme = Theme.of(context);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(16, 10, 16, 12),
            child: Text(
              title,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          if (items.isEmpty)
            _EmptyCart()
          else ...[
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: items.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final item = items[index];
                return _CartItemCard(
                  item: item,
                  currencyLabel: currencyLabel,
                  onTap: onItemTap == null ? null : () => onItemTap!(item),
                  onIncrease: onIncrease == null ? null : () => onIncrease!(item),
                  onDecrease: onDecrease == null ? null : () => onDecrease!(item),
                  onRemove: onRemove == null ? null : () => onRemove!(item),
                );
              },
            ),
            if (showSummary) ...[
              const SizedBox(height: 14),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: _CartSummary(
                  total: total,
                  money: _money,
                  showCheckout: showCheckout,
                  checkoutLabel: checkoutLabel,
                  onCheckout: onCheckout,
                ),
              ),
            ],
          ],
        ],
      ),
    );
  }
}

class _CartItemCard extends StatelessWidget {
  final CartItem item;
  final String currencyLabel;
  final VoidCallback? onTap;
  final VoidCallback? onIncrease;
  final VoidCallback? onDecrease;
  final VoidCallback? onRemove;

  const _CartItemCard({
    required this.item,
    required this.currencyLabel,
    this.onTap,
    this.onIncrease,
    this.onDecrease,
    this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final image = item.imageUrl;

    return Material(
      color: theme.colorScheme.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: SizedBox(
                  width: 92,
                  height: 92,
                  child: image == null
                      ? const ColoredBox(
                          color: Colors.black12,
                          child: Icon(Icons.image_outlined),
                        )
                      : Image.network(
                          image,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => const ColoredBox(
                            color: Colors.black12,
                            child: Icon(Icons.image_not_supported_outlined),
                          ),
                        ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            item.title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        IconButton(
                          visualDensity: VisualDensity.compact,
                          onPressed: onRemove,
                          tooltip: 'حذف',
                          icon: const Icon(Icons.delete_outline),
                        ),
                      ],
                    ),
                    if (!item.isAvailable)
                      Text(
                        'ناموجود',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.error,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    const SizedBox(height: 8),
                    Text(
                      '${item.price} $currencyLabel',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    if (item.oldPrice != null && item.oldPrice! > item.price)
                      Text(
                        '${item.oldPrice} $currencyLabel',
                        style: theme.textTheme.bodySmall?.copyWith(
                          decoration: TextDecoration.lineThrough,
                        ),
                      ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        _QuantityButton(
                          icon: Icons.add,
                          onPressed: onIncrease,
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: Text(
                            item.quantity.toString(),
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                        _QuantityButton(
                          icon: Icons.remove,
                          onPressed: onDecrease,
                        ),
                      ],
                    ),
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

class _QuantityButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;

  const _QuantityButton({required this.icon, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 36,
      height: 36,
      child: IconButton.filledTonal(
        padding: EdgeInsets.zero,
        onPressed: onPressed,
        icon: Icon(icon, size: 18),
      ),
    );
  }
}

class _CartSummary extends StatelessWidget {
  final int total;
  final String Function(int) money;
  final bool showCheckout;
  final String checkoutLabel;
  final VoidCallback? onCheckout;

  const _CartSummary({
    required this.total,
    required this.money,
    required this.showCheckout,
    required this.checkoutLabel,
    this.onCheckout,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Expanded(child: Text('جمع سبد خرید')),
              Text(
                money(total),
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          if (showCheckout) ...[
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: onCheckout,
                child: Text(checkoutLabel),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _EmptyCart extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 48),
      child: Center(
        child: Column(
          children: [
            Icon(
              Icons.shopping_cart_outlined,
              size: 64,
              color: theme.colorScheme.outline,
            ),
            const SizedBox(height: 12),
            Text(
              'سبد خرید شما خالی است.',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
