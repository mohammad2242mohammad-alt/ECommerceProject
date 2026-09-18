import 'package:flutter/material.dart';

import '../../../core/routes/app_routes.dart';
import '../../../data/models/product_model.dart';
import '../../../shared/widgets/store_widgets.dart';
import '../../products/widgets/product_card.dart';

class FavoritesLoginRequired extends StatelessWidget {
  const FavoritesLoginRequired({super.key});

  @override
  Widget build(BuildContext context) {
    return const EmptyState(
      message: 'برای دیدن علاقه‌مندی‌ها وارد حساب شوید',
      icon: Icons.lock_outline,
    );
  }
}

class FavoritesEmptyState extends StatelessWidget {
  const FavoritesEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    return const EmptyState(
      message: 'محصولی به علاقه‌مندی‌ها اضافه نکرده‌اید',
      icon: Icons.favorite_border,
    );
  }
}

class FavoritesProductGrid extends StatelessWidget {
  const FavoritesProductGrid({
    super.key,
    required this.products,
    this.onProductTap,
    this.onRemoveFavorite,
  });

  final List<ProductModel> products;
  final ValueChanged<ProductModel>? onProductTap;
  final ValueChanged<ProductModel>? onRemoveFavorite;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final count = constraints.maxWidth >= 900
            ? 4
            : constraints.maxWidth >= 600
                ? 3
                : 2;

        return GridView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: products.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: count,
            childAspectRatio: .62,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
          ),
          itemBuilder: (context, index) {
            final product = products[index];

            return ProductCard(
              product: product,
              onTap: onProductTap == null
                  ? null
                  : () => onProductTap!(product),
              onFavorite: onRemoveFavorite == null
                  ? null
                  : () => onRemoveFavorite!(product),
            );
          },
        );
      },
    );
  }
}
