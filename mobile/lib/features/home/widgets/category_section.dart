import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../providers/category_provider.dart';
import '../../../shared/widgets/app_empty.dart';
import '../../../shared/widgets/app_error.dart';
import '../../../shared/widgets/app_loading.dart';

class CategorySection extends ConsumerWidget {
  const CategorySection({super.key});

  Future<void> _openCategory(
    BuildContext context,
    int categoryId,
  ) async {
    if (kIsWeb) {
      // Keep the URL shareable and open the category in a separate browser tab.
      final current = Uri.base;
      final uri = current.replace(
        path: '/products',
        queryParameters: {'category_id': categoryId.toString()},
      );

      await launchUrl(uri, webOnlyWindowName: '_blank');
      return;
    }

    // On Android/iOS/desktop, use the app's own navigation.
    Navigator.pushNamed(
      context,
      '/products',
      arguments: categoryId,
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsync = ref.watch(categoriesProvider);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'دسته‌بندی‌ها',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 14),
          categoriesAsync.when(
            loading: () => const AppLoading(),
            error: (error, stackTrace) {
              debugPrint('CATEGORY ERROR: $error');
              debugPrint('CATEGORY STACK: $stackTrace');

              return AppError(
                message: 'خطا در دریافت دسته‌بندی‌ها',
                onRetry: () => ref.invalidate(categoriesProvider),
              );
            },
            data: (categories) {
              if (categories.isEmpty) {
                return const AppEmpty(
                  message: 'دسته‌بندی‌ای وجود ندارد',
                  icon: Icons.category_outlined,
                );
              }

              return SizedBox(
                height: 115,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: categories.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 14),
                  itemBuilder: (context, index) {
                    final category = categories[index];

                    return InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () => _openCategory(context, category.id),
                      child: SizedBox(
                        width: 90,
                        child: Column(
                          children: [
                            Container(
                              width: 68,
                              height: 68,
                              decoration: BoxDecoration(
                                color: Colors.grey.shade100,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.grey.shade200,
                                ),
                              ),
                              child: category.image != null &&
                                      category.image!.isNotEmpty
                                  ? ClipOval(
                                      child: Image.network(
                                        category.image!,
                                        width: 68,
                                        height: 68,
                                        fit: BoxFit.cover,
                                        errorBuilder: (_, __, ___) =>
                                            const Icon(
                                          Icons.category_outlined,
                                          size: 32,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    )
                                  : const Icon(
                                      Icons.category_outlined,
                                      size: 32,
                                      color: Colors.grey,
                                    ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              category.name,
                              maxLines: 2,
                              textAlign: TextAlign.center,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
