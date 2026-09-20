import 'package:flutter/material.dart';

/// Data model for a reusable brand tile.
class BrandItem {
  final String id;
  final String name;
  final String? logoUrl;
  final IconData fallbackIcon;

  const BrandItem({
    required this.id,
    required this.name,
    this.logoUrl,
    this.fallbackIcon = Icons.storefront_outlined,
  });
}

/// Reusable horizontal brand section. Navigation and data fetching stay
/// outside the UI library.
class BrandComponent extends StatelessWidget {
  final List<BrandItem> items;
  final ValueChanged<BrandItem>? onTap;
  final String title;
  final String? subtitle;
  final double itemWidth;
  final double itemHeight;
  final double spacing;
  final EdgeInsetsGeometry padding;
  final bool showTitle;

  const BrandComponent({
    super.key,
    required this.items,
    this.onTap,
    this.title = 'برندهای محبوب',
    this.subtitle,
    this.itemWidth = 104,
    this.itemHeight = 116,
    this.spacing = 12,
    this.padding = const EdgeInsets.symmetric(horizontal: 16),
    this.showTitle = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (showTitle)
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
                          Text(
                            subtitle!,
                            style: theme.textTheme.bodySmall,
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          SizedBox(
            height: itemHeight,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: padding,
              itemCount: items.length,
              separatorBuilder: (_, __) => SizedBox(width: spacing),
              itemBuilder: (context, index) {
                final brand = items[index];
                return SizedBox(
                  width: itemWidth,
                  child: Material(
                    color: theme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(18),
                    child: InkWell(
                      onTap: onTap == null ? null : () => onTap!(brand),
                      borderRadius: BorderRadius.circular(18),
                      child: Padding(
                        padding: const EdgeInsets.all(10),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Expanded(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(14),
                                child: brand.logoUrl == null
                                    ? Center(
                                        child: Icon(
                                          brand.fallbackIcon,
                                          size: 38,
                                          color: theme.colorScheme.primary,
                                        ),
                                      )
                                    : Image.network(
                                        brand.logoUrl!,
                                        width: double.infinity,
                                        fit: BoxFit.contain,
                                        errorBuilder: (_, __, ___) => Center(
                                          child: Icon(
                                            brand.fallbackIcon,
                                            size: 38,
                                            color: theme.colorScheme.primary,
                                          ),
                                        ),
                                      ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              brand.name,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.center,
                              style: theme.textTheme.bodySmall?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
