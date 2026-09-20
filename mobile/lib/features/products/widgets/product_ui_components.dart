import 'package:flutter/material.dart';

import '../../../core/routes/app_routes.dart';
import '../../../data/models/home_model.dart';
import '../../../data/models/product_model.dart';
import '../../../shared/widgets/shared_widgets.dart';
import 'product_card.dart';

class ProductSearchBar extends StatelessWidget {
  const ProductSearchBar({
    super.key,
    required this.controller,
    required this.onSubmitted,
  });

  final TextEditingController controller;
  final ValueChanged<String> onSubmitted;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      textInputAction: TextInputAction.search,
      onSubmitted: onSubmitted,
      decoration: InputDecoration(
        hintText: 'جستجوی محصول',
        prefixIcon: const Icon(Icons.search),
        filled: true,
        fillColor: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: .45),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(
            color: Theme.of(context).colorScheme.outlineVariant.withValues(alpha: .45),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(
            color: Theme.of(context).colorScheme.primary,
            width: 1.4,
          ),
        ),
      ),
    );
  }
}

class ProductSortMenu extends StatelessWidget {
  const ProductSortMenu({
    super.key,
    required this.value,
    required this.onSelected,
  });

  final String value;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.sort),
      tooltip: 'مرتب‌سازی',
      initialValue: value,
      onSelected: onSelected,
      itemBuilder: (_) => const [
        PopupMenuItem(value: 'newest', child: Text('جدیدترین')),
        PopupMenuItem(value: 'price_asc', child: Text('ارزان‌ترین')),
        PopupMenuItem(value: 'price_desc', child: Text('گران‌ترین')),
        PopupMenuItem(value: 'rating_desc', child: Text('بالاترین امتیاز')),
      ],
    );
  }
}

class ProductGridSection extends StatelessWidget {
  const ProductGridSection({
    super.key,
    required this.products,
    this.onProductTap,
  });

  final List<ProductModel> products;
  final ValueChanged<ProductModel>? onProductTap;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final count = constraints.maxWidth >= 1050
            ? 5
            : constraints.maxWidth >= 800
                ? 4
                : constraints.maxWidth >= 560
                    ? 3
                    : 2;

        return GridView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: products.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: count,
            childAspectRatio: .62,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
          ),
          itemBuilder: (context, index) {
            final product = products[index];
            return ProductCard(
              product: product,
              onTap: onProductTap == null ? null : () => onProductTap!(product),
            );
          },
        );
      },
    );
  }
}

class ProductPagination extends StatelessWidget {
  const ProductPagination({
    super.key,
    required this.page,
    required this.onPrevious,
    required this.onNext,
  });

  final ProductPage page;
  final VoidCallback? onPrevious;
  final VoidCallback? onNext;

  @override
  Widget build(BuildContext context) {
    if (page.lastPage <= 1) {
      return const SizedBox.shrink();
    }

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              onPressed: onPrevious,
              tooltip: 'صفحه قبل',
              icon: const Icon(Icons.chevron_right),
            ),
            Text('صفحه ${page.currentPage} از ${page.lastPage}'),
            IconButton(
              onPressed: onNext,
              tooltip: 'صفحه بعد',
              icon: const Icon(Icons.chevron_left),
            ),
          ],
        ),
      ),
    );
  }
}

class ProductListSection extends StatelessWidget {
  const ProductListSection({
    super.key,
    required this.page,
    this.onProductTap,
    this.onPrevious,
    this.onNext,
  });

  final ProductPage page;
  final ValueChanged<ProductModel>? onProductTap;
  final VoidCallback? onPrevious;
  final VoidCallback? onNext;

  @override
  Widget build(BuildContext context) {
    if (page.items.isEmpty) {
      return const EmptyState(
        message: 'محصولی پیدا نشد',
        icon: Icons.search_off,
      );
    }

    return Column(
      children: [
        Expanded(
          child: ProductGridSection(
            products: page.items,
            onProductTap: onProductTap,
          ),
        ),
        ProductPagination(
          page: page,
          onPrevious: onPrevious,
          onNext: onNext,
        ),
      ],
    );
  }
}
