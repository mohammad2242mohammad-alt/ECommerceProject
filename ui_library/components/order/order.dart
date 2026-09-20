import 'package:flutter/material.dart';

class OrderItem {
  final String id;
  final String title;
  final String status;
  final String totalLabel;
  final String dateLabel;
  final String? imageUrl;

  const OrderItem({
    required this.id,
    required this.title,
    required this.status,
    required this.totalLabel,
    required this.dateLabel,
    this.imageUrl,
  });
}

/// Reusable order list UI. Order status and business rules come from the
/// backend; this component only presents supplied values.
class OrderComponent extends StatelessWidget {
  final List<OrderItem> orders;
  final ValueChanged<OrderItem>? onOrderTap;
  final String title;
  final String emptyTitle;
  final String emptySubtitle;

  const OrderComponent({
    super.key,
    required this.orders,
    this.onOrderTap,
    this.title = 'سفارش‌های من',
    this.emptyTitle = 'هنوز سفارشی ثبت نکرده‌اید',
    this.emptySubtitle = 'سفارش‌های شما پس از ثبت در اینجا نمایش داده می‌شوند.',
  });

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w900,
                ),
          ),
          const SizedBox(height: 16),
          if (orders.isEmpty)
            _EmptyOrders(title: emptyTitle, subtitle: emptySubtitle)
          else
            for (final order in orders) ...[
              _OrderCard(order: order, onTap: onOrderTap),
              const SizedBox(height: 10),
            ],
        ],
      ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  final OrderItem order;
  final ValueChanged<OrderItem>? onTap;

  const _OrderCard({required this.order, this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final card = Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            _OrderImage(url: order.imageUrl),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    order.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 7),
                  Text(order.dateLabel, style: theme.textTheme.bodySmall),
                  const SizedBox(height: 7),
                  Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    children: [
                      _StatusChip(label: order.status),
                      Text(
                        order.totalLabel,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.chevron_left),
          ],
        ),
      ),
    );

    if (onTap == null) return card;
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () => onTap!(order),
      child: card,
    );
  }
}

class _OrderImage extends StatelessWidget {
  final String? url;
  const _OrderImage({this.url});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: SizedBox(
        width: 72,
        height: 72,
        child: url == null || url!.isEmpty
            ? const ColoredBox(
                color: Color(0xFFEDEDED),
                child: Icon(Icons.receipt_long_outlined),
              )
            : Image.network(
                url!,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const ColoredBox(
                  color: Color(0xFFEDEDED),
                  child: Icon(Icons.receipt_long_outlined),
                ),
              ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String label;
  const _StatusChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.secondaryContainer,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
      ),
    );
  }
}

class _EmptyOrders extends StatelessWidget {
  final String title;
  final String subtitle;
  const _EmptyOrders({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          children: [
            const Icon(Icons.receipt_long_outlined, size: 52),
            const SizedBox(height: 12),
            Text(
              title,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
            ),
            const SizedBox(height: 6),
            Text(subtitle, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
