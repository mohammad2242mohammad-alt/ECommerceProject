import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/models/category_model.dart';
import '../../../providers/category_provider.dart';
import '../../../providers/product_provider.dart';
import '../../../shared/widgets/app_empty.dart';
import '../../../shared/widgets/app_error.dart';
import '../../../shared/widgets/app_loading.dart';
import '../widgets/product_card.dart';

class ProductsScreen extends ConsumerWidget {
  const ProductsScreen({
    super.key,
    this.categoryId,
  });

  final int? categoryId;

  Category? _findCategory(List<Category> categories, int id) {
    for (final category in categories) {
      if (category.id == id) return category;

      final child = _findCategory(category.children, id);
      if (child != null) return child;
    }
    return null;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productsAsync = ref.watch(productsProvider(categoryId));
    final categoriesAsync = categoryId == null
        ? null
        : ref.watch(categoriesProvider);

    final categoryName = categoryId == null
        ? null
        : categoriesAsync?.when(
            loading: () => null,
            error: (_, _) => null,
            data: (categories) => _findCategory(categories, categoryId!)?.name,
          );

    return Scaffold(
      backgroundColor: const Color(0xFFF1F2F4),
      appBar: AppBar(
        backgroundColor: const Color(0xFFE2E4E8),
        surfaceTintColor: Colors.transparent,
        title: Text(
          categoryName ?? (categoryId == null ? 'محصولات' : 'محصولات'),
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFF25282D),
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: productsAsync.when(
          loading: () => const AppLoading(),
          error: (error, stackTrace) {
            debugPrint('PRODUCTS SCREEN ERROR: $error');
            debugPrint('PRODUCTS SCREEN STACK: $stackTrace');

            return AppError(
              message: 'خطا در دریافت محصولات',
              onRetry: () {
                ref.invalidate(productsProvider(categoryId));
              },
            );
          },
          data: (products) {
            if (products.isEmpty) {
              return const AppEmpty(
                message: 'محصولی در این دسته وجود ندارد',
                icon: Icons.inventory_2_outlined,
              );
            }

            return LayoutBuilder(
              builder: (context, constraints) {
                final width = constraints.maxWidth;
                final columns = width >= 1200
                    ? 5
                    : width >= 900
                        ? 4
                        : width >= 600
                            ? 3
                            : 2;

                return GridView.builder(
                  physics: const AlwaysScrollableScrollPhysics(),
                  itemCount: products.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: columns,
                    childAspectRatio: 0.72,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  itemBuilder: (context, index) {
                    return ProductCard(product: products[index]);
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }
}
