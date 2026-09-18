import 'package:flutter/material.dart';

/// Reusable page layout engine: sections are built once and can be reordered
/// by passing a different section list. Keep business/data logic outside.
class LayoutEngine extends StatelessWidget {
  final List<Widget> sections;
  final EdgeInsetsGeometry padding;
  final bool shrinkWrap;

  const LayoutEngine({
    super.key,
    required this.sections,
    this.padding = EdgeInsets.zero,
    this.shrinkWrap = false,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: padding,
      shrinkWrap: shrinkWrap,
      physics: shrinkWrap
          ? const NeverScrollableScrollPhysics()
          : const AlwaysScrollableScrollPhysics(),
      itemCount: sections.length,
      separatorBuilder: (_, __) => const SizedBox.shrink(),
      itemBuilder: (_, index) => sections[index],
    );
  }
}

/// A named reusable section used by configurable page layouts.
class LayoutSection {
  final String id;
  final WidgetBuilder builder;

  const LayoutSection({required this.id, required this.builder});
}

/// Builds a page from an ordered list of reusable sections.
class ConfigurableLayout extends StatelessWidget {
  final List<LayoutSection> sections;
  final EdgeInsetsGeometry padding;

  const ConfigurableLayout({
    super.key,
    required this.sections,
    this.padding = EdgeInsets.zero,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutEngine(
      padding: padding,
      sections: [
        for (final section in sections) section.builder(context),
      ],
    );
  }
}
