import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/models/category_model.dart';
import '../../../providers/category_provider.dart';
import '../../categories/screens/category_screen.dart';
import '../../../shared/widgets/app_empty.dart';
import '../../../shared/widgets/app_error.dart';
import '../../../shared/widgets/app_loading.dart';

class CategorySection extends ConsumerWidget {
  const CategorySection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsync = ref.watch(categoriesProvider);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 4,
                height: 24,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                'دسته‌بندی‌ها',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          SizedBox(
            height: 145,
            child: categoriesAsync.when(
              loading: () => const AppLoading(),
              error: (error, stackTrace) {
                debugPrint('CATEGORY ERROR: $error');

                return AppError(
                  message: 'خطا در دریافت دسته‌بندی‌ها',
                  onRetry: () {
                    ref.invalidate(categoriesProvider);
                  },
                );
              },
              data: (categories) {
                if (categories.isEmpty) {
                  return const AppEmpty(
                    message: 'دسته‌بندی‌ای وجود ندارد',
                    icon: Icons.category_outlined,
                  );
                }

                return ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  itemCount: categories.length,
                  separatorBuilder: (_, _) =>
                      const SizedBox(width: 12),
                  itemBuilder: (context, index) {
                    final category = categories[index];

                    return CategoryItem(
                      category: category,
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class CategoryItem extends StatelessWidget {
  const CategoryItem({
    super.key,
    required this.category,
  });

  final Category category;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return SizedBox(
      width: 105,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => CategoryScreen(
                categoryId: category.id,
              ),
            ),
          );
        },
        child: Column(
          children: [
            Container(
              width: 82,
              height: 82,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: colorScheme.primaryContainer,
                border: Border.all(
                  color: colorScheme.primary.withValues(
                    alpha: 0.15,
                  ),
                ),
                boxShadow: [
                  BoxShadow(
                    color: colorScheme.primary.withValues(
                      alpha: 0.08,
                    ),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: category.image != null &&
                      category.image!.isNotEmpty
                  ? ClipOval(
                      child: Image.network(
                        category.image!,
                        fit: BoxFit.cover,
                        errorBuilder: (
                          context,
                          error,
                          stackTrace,
                        ) {
                          return Icon(
                            Icons.category_outlined,
                            size: 38,
                            color: colorScheme.primary,
                          );
                        },
                      ),
                    )
                  : Icon(
                      Icons.category_outlined,
                      size: 38,
                      color: colorScheme.primary,
                    ),
            ),
            const SizedBox(height: 9),
            Text(
              category.name,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}