import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/models/category_model.dart';
import '../../../providers/category_provider.dart';
import '../../../shared/widgets/app_empty.dart';
import '../../../shared/widgets/app_error.dart';
import '../../../shared/widgets/app_loading.dart';

class CategoryScreen extends ConsumerWidget {
  const CategoryScreen({
    super.key,
    required this.categoryId,
  });

  final int categoryId;

  Category? _findCategory(
    List<Category> categories,
    int id,
  ) {
    for (final category in categories) {
      if (category.id == id) {
        return category;
      }

      final child = _findCategory(
        category.children,
        id,
      );

      if (child != null) {
        return child;
      }
    }

    return null;
  }

  @override
  Widget build(
    BuildContext context,
    WidgetRef ref,
  ) {
    final categoriesAsync = ref.watch(
      categoriesProvider,
    );

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text(
          'دسته‌بندی',
        ),
        centerTitle: true,
      ),
      body: categoriesAsync.when(
        loading: () {
          return const AppLoading();
        },
        error: (error, stackTrace) {
          debugPrint(
            'CATEGORY ERROR: $error',
          );

          return AppError(
            message: 'خطا در دریافت دسته‌بندی‌ها',
            onRetry: () {
              ref.invalidate(
                categoriesProvider,
              );
            },
          );
        },
        data: (categories) {
          final category = _findCategory(
            categories,
            categoryId,
          );

          if (category == null) {
            return const AppEmpty(
              message: 'دسته‌بندی پیدا نشد',
              icon: Icons.category_outlined,
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(
                categoriesProvider,
              );

              await ref.read(
                categoriesProvider.future,
              );
            },
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Text(
                  category.name,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                if (category.description != null &&
                    category.description!
                        .trim()
                        .isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    category.description!,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                ],

                if (category.children.isNotEmpty) ...[
                  const SizedBox(height: 24),

                  const Text(
                    'زیر‌دسته‌ها',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 12),

                  GridView.builder(
                    shrinkWrap: true,
                    physics:
                        const NeverScrollableScrollPhysics(),
                    itemCount:
                        category.children.length,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 1.15,
                    ),
                    itemBuilder: (
                      context,
                      index,
                    ) {
                      final child =
                          category.children[index];

                      return Card(
                        elevation: 2,
                        child: InkWell(
                          borderRadius:
                              BorderRadius.circular(12),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    CategoryScreen(
                                  categoryId:
                                      child.id,
                                ),
                              ),
                            );
                          },
                          child: Center(
                            child: Padding(
                              padding:
                                  const EdgeInsets.all(12),
                              child: Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.center,
                                children: [
                                  const Icon(
                                    Icons.category_outlined,
                                    size: 40,
                                  ),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  Text(
                                    child.name,
                                    textAlign:
                                        TextAlign.center,
                                    maxLines: 2,
                                    overflow:
                                        TextOverflow.ellipsis,
                                    style:
                                        const TextStyle(
                                      fontSize: 16,
                                      fontWeight:
                                          FontWeight.bold,
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
                ],

                const SizedBox(height: 30),

                const Text(
                  'محصولات این دسته',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 12),

                const Card(
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: Center(
                      child: Text(
                        'بخش محصولات این دسته در مرحله بعد متصل می‌شود.',
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}