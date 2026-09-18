import 'package:flutter/material.dart';

import '../../components/brand/brand.dart';
import '../../components/category/category.dart';
import '../../components/product_card/product_card.dart';
import '../../components/product_grid/product_grid.dart';

/// Reusable Category sections. Data, navigation, filtering and business rules
/// stay outside this layer so the same sections can be rearranged freely.
class CategorySections {
  const CategorySections._();

  static Widget header({
    required String title,
    String? subtitle,
    Widget? trailing,
  }) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  if (subtitle != null) ...[
                    const SizedBox(height: 4),
                    Text(subtitle, style: TextStyle(color: Colors.grey)),
                  ],
                ],
              ),
            ),
            if (trailing != null) trailing,
          ],
        ),
      ),
    );
  }

  static Widget subcategories({
    required List<CategoryItem> items,
    ValueChanged<CategoryItem>? onTap,
    String title = 'زیر‌دسته‌ها',
  }) {
    return CategoryComponent(items: items, onTap: onTap, showTitle: true, title: title);
  }

  static Widget filters({
    required Widget filterSection,
    String title = 'فیلتر و مرتب‌سازی',
  }) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
            child: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
          ),
          filterSection,
        ],
      ),
    );
  }

  static Widget products({
    required List<ProductCardItem> products,
    ValueChanged<ProductCardItem>? onProductTap,
    ValueChanged<ProductCardItem>? onAddToCart,
    ValueChanged<ProductCardItem>? onFavoriteTap,
    String title = 'محصولات',
    int columns = 2,
  }) {
    return ProductGridComponent(
      products: products,
      title: title,
      columns: columns,
      onProductTap: onProductTap,
      onAddToCart: onAddToCart,
      onFavoriteTap: onFavoriteTap,
    );
  }

  static Widget brands({
    required List<BrandItem> items,
    ValueChanged<BrandItem>? onTap,
    String title = 'برندهای این دسته',
  }) {
    return BrandComponent(items: items, title: title, onTap: onTap);
  }
}
