import 'package:flutter/material.dart';

class HomeSectionSurface extends StatelessWidget {
  const HomeSectionSurface({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.only(bottom: 4),
  });

  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Container(
      margin: const EdgeInsets.fromLTRB(12, 6, 12, 6),
      padding: padding,
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: scheme.outlineVariant.withValues(alpha: .55)),
      ),
      child: child,
    );
  }
}
