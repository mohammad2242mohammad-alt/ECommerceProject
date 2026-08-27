import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/models/category_model.dart';
import '../../../providers/category_provider.dart';
import '../../../providers/product_provider.dart';
import '../../../shared/widgets/app_empty.dart';
import '../../../shared/widgets/app_error.dart';
import '../../../shared/widgets/app_loading.dart';
import '../../products/widgets/product_card.dart';

class CategoryScreen extends ConsumerWidget {
  const CategoryScreen({
    super.key,
    required this.categoryId,
  });

  final int categoryId;

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
    final categoriesAsync = ref.watch(categoriesProvider);
    final productsAsync = ref.watch(
      popularProductsByCategoryProvider(categoryId),
    );

    return Scaffold(
      backgroundColor: const Color(0xFFF1F2F4),
      appBar: AppBar(
        backgroundColor: const Color(0xFFE2E4E8),
        surfaceTintColor: Colors.transparent,
        title: categoriesAsync.when(
          loading: () => const Text('دسته‌بندی'),
          error: (_, _) => const Text('دسته‌بندی'),
          data: (categories) {
            final category = _findCategory(categories, categoryId);
            return Text(category?.name ?? 'دسته‌بندی');
          },
        ),
        centerTitle: true,
      ),
      body: categoriesAsync.when(
        loading: () => const AppLoading(),
        error: (error, stackTrace) {
          debugPrint('CATEGORY SCREEN ERROR: $error');
          debugPrint('CATEGORY SCREEN STACK: $stackTrace');
          return AppError(
            message: 'خطا در دریافت دسته‌بندی',
            onRetry: () => ref.invalidate(categoriesProvider),
          );
        },
        data: (categories) {
          final category = _findCategory(categories, categoryId);

          if (category == null) {
            return const AppEmpty(
              message: 'دسته‌بندی پیدا نشد',
              icon: Icons.category_outlined,
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(categoriesProvider);
              ref.invalidate(popularProductsByCategoryProvider(categoryId));
              await ref.read(categoriesProvider.future);
            },
            child: LayoutBuilder(
              builder: (context, constraints) {
                final width = constraints.maxWidth;
                final productColumns = width >= 1200
                    ? 5
                    : width >= 900
                        ? 4
                        : width >= 600
                            ? 3
                            : 2;

                return ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
                  children: [
                    Text(
                      category.name,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF25282D),
                      ),
                    ),
                    if (category.description != null &&
                        category.description!.trim().isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(
                        category.description!,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFF5F6368),
                        ),
                      ),
                    ],
                    if (category.children.isNotEmpty) ...[
                      const SizedBox(height: 24),
                      SizedBox(
                        height: 108,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: category.children.length,
                          separatorBuilder: (_, _) =>
                              const SizedBox(width: 12),
                          itemBuilder: (context, index) {
                            final child = category.children[index];
                            return SizedBox(
                              width: 100,
                              child: Card(
                                margin: EdgeInsets.zero,
                                elevation: 0,
                                color: const Color(0xFFE7E9ED),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                  side: const BorderSide(
                                    color: Color(0xFFD5D8DD),
                                  ),
                                ),
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(14),
                                  onTap: () {
                                    Navigator.pushNamed(
                                      context,
                                      '/products',
                                      arguments: child.id,
                                    );
                                  },
                                  child: Center(
                                    child: Padding(
                                      padding: const EdgeInsets.all(8),
                                      child: Text(
                                        child.name,
                                        maxLines: 2,
                                        textAlign: TextAlign.center,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                          color: Color(0xFF30343A),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                    const SizedBox(height: 28),
                    const Text(
                      'محصولات محبوب',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF25282D),
                      ),
                    ),
                    const SizedBox(height: 14),
                    productsAsync.when(
                      loading: () => const SizedBox(
                        height: 180,
                        child: AppLoading(),
                      ),
                      error: (error, stackTrace) {
                        debugPrint('POPULAR PRODUCTS ERROR: $error');
                        debugPrint('POPULAR PRODUCTS STACK: $stackTrace');
                        return AppError(
                          message: 'خطا در دریافت محصولات محبوب',
                          onRetry: () => ref.invalidate(
                            popularProductsByCategoryProvider(categoryId),
                          ),
                        );
                      },
                      data: (products) {
                        if (products.isEmpty) {
                          return const AppEmpty(
                            message: 'در این دسته هنوز محصولی وجود ندارد',
                            icon: Icons.inventory_2_outlined,
                          );
                        }

                        return GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: products.length,
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: productColumns,
                            childAspectRatio: 0.72,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                          ),
                          itemBuilder: (context, index) => ProductCard(
                            product: products[index],
                          ),
                        );
                      },
                    ),
                  ],
                );
              },
            ),
          );
        },
      ),
    );
  }
}
