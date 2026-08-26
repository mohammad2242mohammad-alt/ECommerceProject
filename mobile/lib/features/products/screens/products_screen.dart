import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../providers/product_provider.dart';
import '../../../shared/widgets/app_empty.dart';
import '../../../shared/widgets/app_error.dart';
import '../../../shared/widgets/app_loading.dart';
import '../widgets/product_card.dart';

class ProductsScreen extends ConsumerWidget {
  const ProductsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productsAsync = ref.watch(productsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('محصولات'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: productsAsync.when(
          loading: () => const AppLoading(),

          error: (error, stackTrace) {
            debugPrint('PRODUCTS SCREEN ERROR: $error');
            debugPrint('PRODUCTS SCREEN STACK: $stackTrace');

            return AppError(
              message: 'خطا در دریافت محصولات',
              onRetry: () {
                ref.invalidate(productsProvider);
              },
            );
          },

          data: (products) {
            if (products.isEmpty) {
              return const AppEmpty(
                message: 'محصولی برای نمایش وجود ندارد',
                icon: Icons.inventory_2_outlined,
              );
            }

            return GridView.builder(
              itemCount: products.length,
              gridDelegate:
                  const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.65,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemBuilder: (context, index) {
                final product = products[index];

                return ProductCard(
                  product: product,
                );
              },
            );
          },
        ),
      ),
    );
  }
}