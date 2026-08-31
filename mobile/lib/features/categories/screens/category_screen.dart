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
      backgroundColor: const Color(0xFFF7F8FA),
      appBar: AppBar(
        title: categoriesAsync.when(
          loading: () => const Text('دسته‌بندی'),
          error: (_, _) => const Text('دسته‌بندی'),
          data: (categories) {
            final category = _findCategory(
              categories,
              categoryId,
            );

            return Text(
              category?.name ?? 'دسته‌بندی',
            );
          },
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
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(
                            alpha: 0.05,
                          ),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        Text(
                          category.name,
                          style: const TextStyle(
                            fontSize: 25,
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
                              height: 1.7,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),

                  if (category.children.isNotEmpty) ...[
                    const SizedBox(height: 24),

                    Row(
                      children: [
                        Container(
                          width: 4,
                          height: 24,
                          decoration: BoxDecoration(
                            color: Theme.of(context)
                                .colorScheme
                                .primary,
                            borderRadius:
                                BorderRadius.circular(10),
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'زیر‌دسته‌ها',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 14),

                    LayoutBuilder(
                      builder: (
                        context,
                        constraints,
                      ) {
                        final width = constraints.maxWidth;

                        int columns;

                        if (width >= 1000) {
                          columns = 5;
                        } else if (width >= 700) {
                          columns = 4;
                        } else if (width >= 500) {
                          columns = 3;
                        } else {
                          columns = 2;
                        }

                        return GridView.builder(
                          shrinkWrap: true,
                          physics:
                              const NeverScrollableScrollPhysics(),
                          itemCount:
                              category.children.length,
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: columns,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                            childAspectRatio: 1.05,
                          ),
                          itemBuilder: (
                            context,
                            index,
                          ) {
                            final child =
                                category.children[index];

                            return Material(
                              color: Colors.white,
                              borderRadius:
                                  BorderRadius.circular(18),
                              child: InkWell(
                                borderRadius:
                                    BorderRadius.circular(18),
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
                                child: Padding(
                                  padding:
                                      const EdgeInsets.all(12),
                                  child: Column(
                                    mainAxisAlignment:
                                        MainAxisAlignment.center,
                                    children: [
                                      Container(
                                        width: 58,
                                        height: 58,
                                        decoration:
                                            BoxDecoration(
                                          shape:
                                              BoxShape.circle,
                                          color: Theme.of(
                                            context,
                                          )
                                              .colorScheme
                                              .primaryContainer,
                                        ),
                                        child: Icon(
                                          Icons
                                              .category_outlined,
                                          color: Theme.of(
                                            context,
                                          )
                                              .colorScheme
                                              .primary,
                                          size: 30,
                                        ),
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
                                            TextOverflow
                                                .ellipsis,
                                        style:
                                            const TextStyle(
                                          fontSize: 14,
                                          fontWeight:
                                              FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ],

                  const SizedBox(height: 30),

                  Row(
                    children: [
                      Container(
                        width: 4,
                        height: 24,
                        decoration: BoxDecoration(
                          color: Theme.of(context)
                              .colorScheme
                              .primary,
                          borderRadius:
                              BorderRadius.circular(10),
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'محصولات این دسته',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 14),

                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: const Center(
                      child: Text(
                        'محصولات این دسته در مرحله بعد نمایش داده می‌شوند.',
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}