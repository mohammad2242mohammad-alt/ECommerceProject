import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/routes/app_routes.dart';
import '../../../providers/store_providers.dart';
import '../../../shared/widgets/store_widgets.dart';
import '../../products/widgets/product_card.dart';

class FavoritesScreen extends ConsumerWidget {
  const FavoritesScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (ref.watch(authUserProvider) == null) return Scaffold(appBar: AppBar(title: const Text('علاقه‌مندی‌ها')), body: const EmptyState(message: 'برای دیدن علاقه‌مندی‌ها وارد حساب شوید', icon: Icons.lock_outline));
    final favorites = ref.watch(favoritesProvider);
    return Scaffold(appBar: AppBar(title: const Text('علاقه‌مندی‌ها')), body: favorites.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Center(child: Text(error.toString())),
      data: (items) => items.isEmpty ? const EmptyState(message: 'محصولی به علاقه‌مندی‌ها اضافه نکرده‌اید', icon: Icons.favorite_border) : LayoutBuilder(builder: (context, constraints) {
        final count = constraints.maxWidth >= 900 ? 4 : constraints.maxWidth >= 600 ? 3 : 2;
        return GridView.builder(padding: const EdgeInsets.all(12), itemCount: items.length, gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: count, childAspectRatio: .62, crossAxisSpacing: 10, mainAxisSpacing: 10), itemBuilder: (context, index) {
          final product = items[index];
          return ProductCard(product: product, onTap: () => Navigator.pushNamed(context, AppRoutes.productDetail, arguments: product.id), onFavorite: () async { await ref.read(storeRepositoryProvider).removeFavorite(product.id); ref.invalidate(favoritesProvider); });
        });
      }),
    ));
  }
}
