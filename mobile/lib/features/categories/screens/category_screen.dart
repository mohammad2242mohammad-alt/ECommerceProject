import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/routes/app_routes.dart';
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

  Future<void> _openChildCategory(
    BuildContext context,
    int childId,
  ) async {
    if (kIsWeb) {
      final current = Uri.base;
      final uri = Uri(
        scheme: current.scheme,
        userInfo: current.userInfo,
        host: current.host,
        port: current.hasPort ? current.port : null,
        path: current.path,
        fragment: '${AppRoutes.products}?category_id=$childId',
      );

      final opened = await launchUrl(
        uri,
        webOnlyWindowName: '_blank',
      );

      if (!opened && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('باز کردن صفحه زیر‌دسته ممکن نشد')),
        );
      }
      return;
    }

    if (context.mounted) {
      Navigator.pushNamed(
        context,
        AppRoutes.products,
        arguments: childId,
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsync = ref.watch(categoriesProvider);
    final productsAsync = ref.watch(
      popularProductsByCategoryProvider(categoryId),
    );

    return Scaffold(
      backgroundColor: const Color(0xFFE9EAED),
      appBar: AppBar(
        backgroundColor: const Color(0xFFD4D7DC),
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

                return Scrollbar(
                  thumbVisibility: true,
                  child: ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(16, 20, 16, 40),
                    children: [
                      Text(
                        category.name,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF202329),
                        ),
                      ),
                      if (category.description != null &&
                          category.description!.trim().isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Text(
                          category.description!,
                          style: const TextStyle(
                            fontSize: 13,
                            color: Color(0xFF4E535A),
                          ),
                        ),
                      ],
                      if (category.children.isNotEmpty) ...[
                        const SizedBox(height: 24),
                        Text(
                          'دسته‌های مرتبط',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF30343A),
                          ),
                        ),
                        const SizedBox(height: 12),
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
                                  color: const Color(0xFFDCE0E5),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                    side: const BorderSide(
                                      color: Color(0xFFC7CBD1),
                                    ),
                                  ),
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(14),
                                    onTap: () => _openChildCategory(
                                      context,
                                      child.id,
                                    ),
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
                                            color: Color(0xFF282C31),
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
                          color: Color(0xFF202329),
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
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
