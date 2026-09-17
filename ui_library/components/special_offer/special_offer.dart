import 'dart:async';

import 'package:flutter/material.dart';

import '../product_card/product_card.dart';

/// Reusable special-offer section. Discount and availability values are
/// supplied by the backend/domain layer; this widget only presents them.
class SpecialOfferComponent extends StatefulWidget {
  final List<ProductCardItem> products;
  final ValueChanged<ProductCardItem>? onProductTap;
  final ValueChanged<ProductCardItem>? onFavoriteTap;
  final ValueChanged<ProductCardItem>? onAddToCart;
  final String title;
  final String? subtitle;
  final Duration? countdown;
  final double cardWidth;
  final double imageHeight;
  final String currencyLabel;
  final EdgeInsetsGeometry padding;

  const SpecialOfferComponent({
    super.key,
    required this.products,
    this.onProductTap,
    this.onFavoriteTap,
    this.onAddToCart,
    this.title = 'پیشنهاد ویژه',
    this.subtitle,
    this.countdown,
    this.cardWidth = 190,
    this.imageHeight = 175,
    this.currencyLabel = 'تومان',
    this.padding = const EdgeInsets.symmetric(horizontal: 16),
  });

  @override
  State<SpecialOfferComponent> createState() => _SpecialOfferComponentState();
}

class _SpecialOfferComponentState extends State<SpecialOfferComponent> {
  Timer? _timer;
  Duration _remaining = Duration.zero;

  @override
  void initState() {
    super.initState();
    _remaining = widget.countdown ?? Duration.zero;
    _startTimer();
  }

  @override
  void didUpdateWidget(covariant SpecialOfferComponent oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.countdown != widget.countdown) {
      _remaining = widget.countdown ?? Duration.zero;
      _startTimer();
    }
  }

  void _startTimer() {
    _timer?.cancel();
    if (widget.countdown == null || _remaining <= Duration.zero) return;

    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      if (_remaining <= const Duration(seconds: 1)) {
        setState(() => _remaining = Duration.zero);
        _timer?.cancel();
        return;
      }
      setState(() => _remaining -= const Duration(seconds: 1));
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String _twoDigits(int value) => value.toString().padLeft(2, '0');

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasCountdown = widget.countdown != null;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: theme.colorScheme.errorContainer,
          borderRadius: BorderRadius.circular(22),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(16, 0, 16, 12),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.title,
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        if (widget.subtitle != null) ...[
                          const SizedBox(height: 3),
                          Text(
                            widget.subtitle!,
                            style: theme.textTheme.bodySmall,
                          ),
                        ],
                      ],
                    ),
                  ),
                  if (hasCountdown)
                    _CountdownBadge(
                      remaining: _remaining,
                      twoDigits: _twoDigits,
                    ),
                ],
              ),
            ),
            SizedBox(
              height: widget.imageHeight + 235,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: widget.padding,
                itemCount: widget.products.length,
                separatorBuilder: (_, __) => const SizedBox(width: 10),
                itemBuilder: (context, index) {
                  final product = widget.products[index];
                  return ProductCardComponent(
                    product: product,
                    width: widget.cardWidth,
                    imageHeight: widget.imageHeight,
                    currencyLabel: widget.currencyLabel,
                    onTap: widget.onProductTap == null
                        ? null
                        : () => widget.onProductTap!(product),
                    onFavoriteTap: widget.onFavoriteTap == null
                        ? null
                        : () => widget.onFavoriteTap!(product),
                    onAddToCart: widget.onAddToCart == null
                        ? null
                        : () => widget.onAddToCart!(product),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CountdownBadge extends StatelessWidget {
  final Duration remaining;
  final String Function(int) twoDigits;

  const _CountdownBadge({
    required this.remaining,
    required this.twoDigits,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hours = remaining.inHours;
    final minutes = remaining.inMinutes.remainder(60);
    final seconds = remaining.inSeconds.remainder(60);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Text(
        '${twoDigits(hours)}:${twoDigits(minutes)}:${twoDigits(seconds)}',
        style: theme.textTheme.labelLarge?.copyWith(
          fontWeight: FontWeight.w800,
          fontFeatures: const [FontFeature.tabularFigures()],
        ),
      ),
    );
  }
}
