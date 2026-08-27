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
    final productsAsync = ref.watch(productsProvider(null));

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
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
                onRetry: () => ref.invalidate(productsProvider(null)),
              );
            },
            data: (products) {
              if (products.isEmpty) {
                return const AppEmpty(
                  message: 'محصولی برای نمایش وجود ندارد',
                  icon: Icons.inventory_2_outlined,
                );
              }

              return LayoutBuilder(
                builder: (context, constraints) {
                  final width = constraints.maxWidth;
                  final columns = width >= 1200
                      ? 5
                      : width >= 900
                          ? 4
                          : width >= 600
                              ? 3
                              : 2;

                  return GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: products.length,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: columns,
                      childAspectRatio: 0.72,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                    ),
                    itemBuilder: (context, index) => ProductCard(
                      product: products[index],
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}
