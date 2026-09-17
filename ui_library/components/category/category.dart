import 'package:flutter/material.dart';

/// Data model for a reusable category tile.
class CategoryItem {
  final String id;
  final String title;
  final String? imageUrl;
  final IconData fallbackIcon;

  const CategoryItem({
    required this.id,
    required this.title,
    this.imageUrl,
    this.fallbackIcon = Icons.category_outlined,
  });
}

/// Reusable horizontal category component. Data and navigation stay outside.
class CategoryComponent extends StatelessWidget {
  final List<CategoryItem> items;
  final ValueChanged<CategoryItem>? onTap;
  final double itemWidth;
  final double itemHeight;
  final double spacing;
  final bool showTitle;
  final String title;

  const CategoryComponent({
    super.key,
    required this.items,
    this.onTap,
    this.itemWidth = 92,
    this.itemHeight = 112,
    this.spacing = 12,
    this.showTitle = true,
    this.title = 'دسته‌بندی‌ها',
  });

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (showTitle)
            Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(16, 4, 16, 10),
              child: Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
            ),
          SizedBox(
            height: itemHeight,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: items.length,
              separatorBuilder: (_, __) => SizedBox(width: spacing),
              itemBuilder: (context, index) {
                final item = items[index];
                return SizedBox(
                  width: itemWidth,
                  child: Material(
                    color: Theme.of(context).colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(16),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: onTap == null ? null : () => onTap!(item),
                      child: Padding(
                        padding: const EdgeInsets.all(10),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Expanded(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: item.imageUrl == null
                                    ? Center(
                                        child: Icon(
                                          item.fallbackIcon,
                                          size: 34,
                                        ),
                                      )
                                    : Image.network(
                                        item.imageUrl!,
                                        width: double.infinity,
                                        fit: BoxFit.cover,
                                        errorBuilder: (_, __, ___) => Center(
                                          child: Icon(
                                            item.fallbackIcon,
                                            size: 34,
                                          ),
                                        ),
                                      ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              item.title,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    fontWeight: FontWeight.w600,
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
