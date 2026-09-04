import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/routes/app_routes.dart';
import '../../../providers/store_providers.dart';
import '../../../shared/widgets/store_widgets.dart';

class CategoriesScreen extends ConsumerWidget {
  const CategoriesScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categories = ref.watch(allCategoriesProvider);
    return Scaffold(appBar: AppBar(title: const Text('دسته‌بندی‌ها')), body: categories.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Center(child: FilledButton(onPressed: () => ref.invalidate(allCategoriesProvider), child: const Text('تلاش مجدد'))),
      data: (items) => items.isEmpty ? const EmptyState(message: 'دسته‌بندی‌ای وجود ندارد') : ListView.builder(padding: const EdgeInsets.all(12), itemCount: items.length, itemBuilder: (context, index) {
        final category = items[index];
        return Card(child: ExpansionTile(leading: NetworkImageBox(url: category.image, width: 48, height: 48, fit: BoxFit.contain), title: Text(category.name), onExpansionChanged: (open) { if (!open && category.children.isEmpty) Navigator.pushNamed(context, AppRoutes.products, arguments: {'category_id': category.id, 'title': category.name}); }, children: [
          if (category.children.isEmpty) ListTile(title: const Text('مشاهده محصولات'), trailing: const Icon(Icons.chevron_left), onTap: () => Navigator.pushNamed(context, AppRoutes.products, arguments: {'category_id': category.id, 'title': category.name})),
          ...category.children.map((child) => ListTile(title: Text(child.name), trailing: const Icon(Icons.chevron_left), onTap: () => Navigator.pushNamed(context, AppRoutes.products, arguments: {'category_id': child.id, 'title': child.name}))),
        ]));
      }),
    ));
  }
}
