import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../providers/product_provider.dart';
import '../../../shared/widgets/app_empty.dart';
import '../../../shared/widgets/app_error.dart';
import '../../../shared/widgets/app_loading.dart';
import '../../products/widgets/product_card.dart';

class ProductSection extends ConsumerWidget {
  const ProductSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productsAsync = ref.watch(productsProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'محصولات ویژه',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),

        productsAsync.when(
          loading: () => const AppLoading(),

          error: (error, stackTrace) {
            debugPrint('PRODUCT ERROR: $error');
            debugPrint('PRODUCT STACK: $stackTrace');

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
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
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
      ],
    );
  }
}