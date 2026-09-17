import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/routes/app_routes.dart';
import '../../../providers/store_providers.dart';
import '../widgets/home_section_surface.dart';
import '../widgets/home_ui_components.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final home = ref.watch(homeProvider);
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: scheme.surfaceContainerLowest,
      body: RefreshIndicator(
        onRefresh: () async => ref.invalidate(homeProvider),
        child: home.when(
          loading: () => ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            children: const [
              SizedBox(
                height: 320,
                child: Center(child: CircularProgressIndicator()),
              ),
            ],
          ),
          error: (error, _) => ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            children: [
              SizedBox(
                height: 500,
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.cloud_off_outlined, size: 48),
                        const SizedBox(height: 14),
                        const Text(
                          'بارگذاری فروشگاه انجام نشد',
                          style: TextStyle(
                            fontWeight: FontWeight.w900,
                            fontSize: 18,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(error.toString(), textAlign: TextAlign.center),
                        const SizedBox(height: 16),
                        FilledButton(
                          onPressed: () => ref.invalidate(homeProvider),
                          child: const Text('تلاش مجدد'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          data: (data) {
            final discounted = data.products
                .where((product) => product.hasDiscount)
                .take(10)
                .toList();

            return ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(0, 0, 0, 24),
              children: [
                StoreHeader(
                  onFavorites: () =>
                      Navigator.pushNamed(context, AppRoutes.favorites),
                  onCart: () => Navigator.pushNamed(context, AppRoutes.cart),
                ),
                Container(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                  decoration: BoxDecoration(
                    color: scheme.surface,
                    border: Border(
                      bottom: BorderSide(
                        color: scheme.outlineVariant.withValues(alpha: .5),
                      ),
                    ),
                  ),
                  child: StoreSearchBar(
                    onSubmitted: (value) {
                      final query = value.trim();
                      if (query.isEmpty) return;
                      Navigator.pushNamed(
                        context,
                        AppRoutes.products,
                        arguments: {'search': query},
                      );
                    },
                  ),
                ),
                const SizedBox(height: 8),
                HomeHeroBanner(
                  items: data.banners,
                  onTap: (banner) {
                    if (banner.linkType == 'product' &&
                        banner.linkValue != null) {
                      final id = int.tryParse(banner.linkValue!);
                      if (id != null) {
                        Navigator.pushNamed(
                          context,
                          AppRoutes.productDetail,
                          arguments: id,
                        );
                      }
                    }
                  },
                ),
                HomeSectionSurface(
                  child: Column(
                    children: [
                      SectionHeader(
                        title: 'دسته‌بندی‌ها',
                        onSeeAll: () => Navigator.pushNamed(
                          context,
                          AppRoutes.categories,
                        ),
                      ),
                      CategoryStrip(
                        items: data.categories,
                        onTap: (category) => Navigator.pushNamed(
                          context,
                          AppRoutes.products,
                          arguments: {
                            'category_id': category.id,
                            'title': category.name,
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                if (discounted.isNotEmpty)
                  HomeSectionSurface(
                    child: SpecialOffersSection(
                      products: discounted,
                      onProductTap: (product) => Navigator.pushNamed(
                        context,
                        AppRoutes.productDetail,
                        arguments: product.id,
                      ),
                    ),
                  ),
                HomeSectionSurface(
                  child: ProductGridSection(
                    products: data.products,
                    onProductTap: (product) => Navigator.pushNamed(
                      context,
                      AppRoutes.productDetail,
                      arguments: product.id,
                    ),
                    onSeeAll: () =>
                        Navigator.pushNamed(context, AppRoutes.products),
                  ),
                ),
                const HomeFooter(),
              ],
            );
          },
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: 0,
        onDestinationSelected: (index) {
          switch (index) {
            case 1:
              Navigator.pushNamed(context, AppRoutes.products);
              break;
            case 2:
              Navigator.pushNamed(context, AppRoutes.cart);
              break;
            case 3:
              Navigator.pushNamed(context, AppRoutes.orders);
              break;
            case 4:
              Navigator.pushNamed(context, AppRoutes.profile);
              break;
          }
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'خانه',
          ),
          NavigationDestination(
            icon: Icon(Icons.grid_view_outlined),
            label: 'محصولات',
          ),
          NavigationDestination(
            icon: Icon(Icons.shopping_cart_outlined),
            label: 'سبد',
          ),
          NavigationDestination(
            icon: Icon(Icons.receipt_long_outlined),
            label: 'سفارش‌ها',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            label: 'حساب',
          ),
        ],
      ),
    );
  }
}
