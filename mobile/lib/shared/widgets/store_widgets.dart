import 'package:flutter/material.dart';

import '../../core/constants/api_constants.dart';
import 'app_empty.dart';

String money(num value) {
  final raw = value == value.roundToDouble()
      ? value.toInt().toString()
      : value.toStringAsFixed(2);
  final chars = raw.split('').reversed.toList();
  final out = <String>[];
  for (var i = 0; i < chars.length; i++) {
    if (i > 0 && i % 3 == 0) out.add(',');
    out.add(chars[i]);
  }
  return out.reversed.join();
}

class NetworkImageBox extends StatelessWidget {
  const NetworkImageBox({
    super.key,
    this.url,
    this.height,
    this.width,
    this.fit = BoxFit.cover,
    this.radius = 12,
  });

  final String? url;
  final double? height;
  final double? width;
  final BoxFit fit;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final resolved = ApiConstants.mediaUrl(url);
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: Container(
        height: height,
        width: width,
        color: Theme.of(context)
            .colorScheme
            .surfaceContainerHighest
            .withOpacity(.45),
        child: resolved.isEmpty
            ? const Center(
                child: Icon(Icons.image_outlined, size: 42, color: Colors.grey),
              )
            : Image.network(
                resolved,
                fit: fit,
                errorBuilder: (_, __, ___) => const Center(
                  child: Icon(
                    Icons.image_not_supported_outlined,
                    size: 42,
                    color: Colors.grey,
                  ),
                ),
              ),
      ),
    );
  }
}

class SectionTitle extends StatelessWidget {
  const SectionTitle({
    super.key,
    required this.title,
    this.onSeeAll,
  });

  final String title;
  final VoidCallback? onSeeAll;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          title,
          style: Theme.of(context)
              .textTheme
              .titleLarge
              ?.copyWith(fontWeight: FontWeight.w800),
        ),
        const Spacer(),
        if (onSeeAll != null)
          TextButton(
            onPressed: onSeeAll,
            child: const Text('مشاهده همه'),
          ),
      ],
    );
  }
}

/// Backward-compatible alias for the shared empty state.
///
/// New code should use [AppEmpty] directly.
class EmptyState extends AppEmpty {
  const EmptyState({
    super.key,
    required super.message,
    super.icon,
    super.title,
    super.actionLabel,
    super.onAction,
  });
}

class StatusChip extends StatelessWidget {
  const StatusChip({
    super.key,
    required this.label,
    this.color,
  });

  final String label;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Text(label),
      backgroundColor: (color ?? Theme.of(context).colorScheme.primary)
          .withOpacity(.12),
      side: BorderSide.none,
      labelStyle: TextStyle(
        color: color ?? Theme.of(context).colorScheme.primary,
        fontSize: 12,
      ),
    );
  }
}

String orderStatusLabel(String status) =>
    const {
      'pending': 'در انتظار پرداخت',
      'confirmed': 'تأیید شده',
      'processing': 'در حال آماده‌سازی',
      'shipped': 'ارسال شده',
      'delivered': 'تحویل شده',
      'cancelled': 'لغو شده',
    }[status] ??
    status;

String paymentStatusLabel(String status) =>
    const {
      'unpaid': 'پرداخت نشده',
      'paid': 'پرداخت موفق',
      'failed': 'پرداخت ناموفق',
      'refunded': 'مرجوع شده',
    }[status] ??
    status;
