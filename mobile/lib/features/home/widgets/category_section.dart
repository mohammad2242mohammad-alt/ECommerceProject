import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/widgets/app_empty.dart';
import '../../../shared/widgets/app_error.dart';
import '../../../shared/widgets/app_loading.dart';
import '../../../providers/category_provider.dart';

class CategorySection extends ConsumerWidget {
  const CategorySection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsync = ref.watch(categoriesProvider);

    return SizedBox(
      height: 150,
      child: categoriesAsync.when(
        loading: () => const AppLoading(),

        error: (error, stackTrace) {
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

          return Directionality(
            textDirection: TextDirection.rtl,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final category = categories[index];

                return CategoryItem(
                  title: category.name,
                  icon: Icons.category,
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class CategoryItem extends StatelessWidget {
  const CategoryItem({
    super.key,
    required this.title,
    required this.icon,
  });

  final String title;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return SizedBox(
      width: 100,
      child: Column(
        children: [
          CircleAvatar(
            radius: 35,
            backgroundColor: colorScheme.primary.withValues(
              alpha: 0.1,
            ),
            child: Icon(
              icon,
              size: 35,
              color: colorScheme.primary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
