import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/routes/app_routes.dart';
import '../../../providers/store_providers.dart';
import '../../../shared/widgets/store_widgets.dart';
import '../widgets/category_ui_components.dart';

class CategoriesScreen extends ConsumerWidget {
  const CategoriesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categories = ref.watch(allCategoriesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('دسته‌بندی‌ها'),
      ),
      body: categories.when(
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (error, _) => Center(
          child: FilledButton(
            onPressed: () => ref.invalidate(allCategoriesProvider),
            child: const Text('تلاش مجدد'),
          ),
        ),
        data: (items) {
          if (items.isEmpty) {
            return const EmptyState(
              message: 'دسته‌بندی‌ای وجود ندارد',
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: items.length,
            itemBuilder: (context, index) {
              final category = items[index];

              final data = CategoryTileData(
                id: category.id,
                name: category.name,
                image: category.image,
                children: [
                  for (final child in category.children)
                    CategoryTileData(
                      id: child.id,
                      name: child.name,
                      image: child.image,
                    ),
                ],
              );

              return CategoryListItem(
                category: data,
                onOpenProducts: (selected) {
                  Navigator.pushNamed(
                    context,
                    AppRoutes.products,
                    arguments: {
                      'category_id': selected.id,
                      'title': selected.name,
                    },
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
