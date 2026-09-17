import 'dart:async';

import 'package:flutter/material.dart';

/// A reusable RTL-friendly banner/slider.
///
/// It owns presentation only. Data loading, navigation and business logic stay
/// outside the component through the supplied items and callbacks.
class BannerItem {
  final String? imageUrl;
  final String title;
  final String? subtitle;
  final String? actionLabel;

  const BannerItem({
    required this.title,
    this.imageUrl,
    this.subtitle,
    this.actionLabel,
  });
}

class BannerComponent extends StatefulWidget {
  final List<BannerItem> items;
  final ValueChanged<BannerItem>? onTap;
  final double height;
  final double radius;
  final Duration autoPlayDuration;
  final bool autoPlay;
  final bool showIndicators;

  const BannerComponent({
    super.key,
    required this.items,
    this.onTap,
    this.height = 180,
    this.radius = 18,
    this.autoPlayDuration = const Duration(seconds: 4),
    this.autoPlay = true,
    this.showIndicators = true,
  });

  @override
  State<BannerComponent> createState() => _BannerComponentState();
}

class _BannerComponentState extends State<BannerComponent> {
  final PageController _controller = PageController();
  Timer? _timer;
  int _index = 0;

  @override
  void initState() {
    super.initState();
    _startAutoPlay();
  }

  @override
  void didUpdateWidget(covariant BannerComponent oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.autoPlay != widget.autoPlay ||
        oldWidget.autoPlayDuration != widget.autoPlayDuration ||
        oldWidget.items.length != widget.items.length) {
      _restartAutoPlay();
    }
  }

  void _startAutoPlay() {
    _timer?.cancel();
    if (!widget.autoPlay || widget.items.length < 2) return;

    _timer = Timer.periodic(widget.autoPlayDuration, (_) {
      if (!_controller.hasClients || widget.items.isEmpty) return;
      final next = (_index + 1) % widget.items.length;
      _controller.animateToPage(
        next,
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeOut,
      );
    });
  }

  void _restartAutoPlay() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _startAutoPlay();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.items.isEmpty) return const SizedBox.shrink();

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            height: widget.height,
            child: PageView.builder(
              controller: _controller,
              itemCount: widget.items.length,
              onPageChanged: (value) => setState(() => _index = value),
              itemBuilder: (context, index) {
                final item = widget.items[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: _BannerCard(
                    item: item,
                    radius: widget.radius,
                    onTap: widget.onTap == null
                        ? null
                        : () => widget.onTap!(item),
                  ),
                );
              },
            ),
          ),
          if (widget.showIndicators && widget.items.length > 1) ...[
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (var i = 0; i < widget.items.length; i++)
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    width: i == _index ? 18 : 7,
                    height: 7,
                    decoration: BoxDecoration(
                      color: i == _index
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context).colorScheme.outlineVariant,
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _BannerCard extends StatelessWidget {
  final BannerItem item;
  final double radius;
  final VoidCallback? onTap;

  const _BannerCard({
    required this.item,
    required this.radius,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: theme.colorScheme.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(radius),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (item.imageUrl != null && item.imageUrl!.isNotEmpty)
              Image.network(
                item.imageUrl!,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const SizedBox.shrink(),
              ),
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.centerRight,
                  end: Alignment.centerLeft,
                  colors: [
                    Colors.black.withValues(alpha: 0.62),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Align(
                alignment: Alignment.centerRight,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 290),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleLarge?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      if (item.subtitle != null) ...[
                        const SizedBox(height: 6),
                        Text(
                          item.subtitle!,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: Colors.white70,
                          ),
                        ),
                      ],
                      if (item.actionLabel != null) ...[
                        const SizedBox(height: 12),
                        FilledButton.tonal(
                          onPressed: onTap,
                          child: Text(item.actionLabel!),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
