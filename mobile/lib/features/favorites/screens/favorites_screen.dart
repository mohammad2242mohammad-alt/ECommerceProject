import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/routes/app_routes.dart';
import '../../../providers/store_providers.dart';
import '../widgets/favorites_ui_components.dart';

class FavoritesScreen extends ConsumerWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (ref.watch(authUserProvider) == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('علاقه‌مندی‌ها')),
        body: const FavoritesLoginRequired(),
      );
    }

    final favorites = ref.watch(favoritesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('علاقه‌مندی‌ها')),
      body: favorites.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text(error.toString())),
        data: (items) => items.isEmpty
            ? const FavoritesEmptyState()
            : FavoritesProductGrid(
                products: items,
                onProductTap: (product) => Navigator.pushNamed(
                  context,
                  AppRoutes.productDetail,
                  arguments: product.id,
                ),
                onRemoveFavorite: (product) async {
                  await ref
                      .read(storeRepositoryProvider)
                      .removeFavorite(product.id);
                  ref.invalidate(favoritesProvider);
                },
              ),
      ),
    );
  }
}
