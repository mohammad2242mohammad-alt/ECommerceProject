import 'package:flutter/material.dart';

import '../../../shared/widgets/store_widgets.dart';

class CategoryTileData {
  const CategoryTileData({
    required this.id,
    required this.name,
    this.image,
    this.children = const <CategoryTileData>[],
  });

  final int id;
  final String name;
  final String? image;
  final List<CategoryTileData> children;
}

class CategoryListItem extends StatelessWidget {
  const CategoryListItem({
    super.key,
    required this.category,
    required this.onOpenProducts,
  });

  final CategoryTileData category;
  final void Function(CategoryTileData category) onOpenProducts;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final hasChildren = category.children.isNotEmpty;

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      elevation: 0,
      clipBehavior: Clip.antiAlias,
      color: scheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(
          color: scheme.outlineVariant.withValues(alpha: .55),
        ),
      ),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
        childrenPadding: const EdgeInsets.only(bottom: 8),
        leading: NetworkImageBox(
          url: category.image,
          width: 52,
          height: 52,
          fit: BoxFit.contain,
        ),
        title: Text(
          category.name,
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        subtitle: Text(
          hasChildren
              ? 'مشاهده زیر‌دسته‌ها'
              : 'مشاهده محصولات',
        ),
        onExpansionChanged: (open) {
          if (!open && !hasChildren) {
            onOpenProducts(category);
          }
        },
        children: [
          if (!hasChildren)
            _CategoryActionTile(
              title: 'مشاهده محصولات',
              onTap: () => onOpenProducts(category),
            ),
          for (final child in category.children)
            _CategoryActionTile(
              title: child.name,
              onTap: () => onOpenProducts(child),
            ),
        ],
      ),
    );
  }
}

class _CategoryActionTile extends StatelessWidget {
  const _CategoryActionTile({
    required this.title,
    required this.onTap,
  });

  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsetsDirectional.only(
        start: 24,
        end: 18,
      ),
      title: Text(title),
      trailing: const Icon(Icons.chevron_left_rounded),
      onTap: onTap,
    );
  }
}
