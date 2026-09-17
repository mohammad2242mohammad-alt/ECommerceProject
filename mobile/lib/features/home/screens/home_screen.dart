import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ecommerce_ui_library/ecommerce_ui_library.dart';

import '../../../core/routes/app_routes.dart';
import '../../../data/models/product_model.dart';
import '../../../providers/store_providers.dart';

class HomeScreen extends ConsumerStatefulWidget {
  /// Change only this id to rearrange the Home without rewriting its sections.
  final String layoutConfig;

  const HomeScreen({super.key, this.layoutConfig = 'home_default'});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  late Future<List<String>> _layoutFuture;

  @override
  void initState() {
    super.initState();
    _layoutFuture = LayoutConfigLoader.load(widget.layoutConfig);
  }

  ProductCardItem _productItem(ProductModel product) {
    int? discountPercent;
    if (product.discountPrice != null &&
        product.discountPrice! > 0 &&
        product.discountPrice! < product.price) {
      discountPercent =
          (((product.price - product.discountPrice!) / product.price) * 100)
              .round();
    }

    return ProductCardItem(
      id: product.id.toString(),
      title: product.name,
      imageUrl: product.image,
      price: product.price.round(),
      discountPrice: product.discountPrice?.round(),
      discountPercent: discountPercent,
      rating: product.ratingAverage,
      reviewCount: product.ratingCount,
      isAvailable: product.stock > 0,
    );
  }

  LayoutSection _buildSection(
    BuildContext context,
    String id,
    List<ProductCardItem> products,
    List<ProductCardItem> specialOffers,
    dynamic data,
  ) {
    switch (id) {
      case 'header':
        return LayoutSection(
          id: id,
          builder: (_) => HeaderComponent(
            title: 'فروشگاه اینترنتی',
            onCart: () => Navigator.pushNamed(context, AppRoutes.cart),
            onProfile: () => Navigator.pushNamed(context, AppRoutes.profile),
            trailing: IconButton(
              tooltip: 'علاقه‌مندی‌ها',
              onPressed: () =>
                  Navigator.pushNamed(context, AppRoutes.favorites),
              icon: const Icon(Icons.favorite_border),
            ),
          ),
        );

      case 'search':
        return LayoutSection(
          id: id,
          builder: (_) => Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 4),
            child: SearchComponent(
              onSubmitted: (value) {
                if (value.trim().isEmpty) return;
                Navigator.pushNamed(
                  context,
                  AppRoutes.products,
                  arguments: {'search': value.trim()},
                );
              },
            ),
          ),
        );

      case 'banner':
        return LayoutSection(
          id: id,
          builder: (_) => HomeSections.banner(
            items: [
              for (final banner in data.banners)
                BannerItem(
                  title: banner.title,
                  imageUrl: banner.image,
                ),
            ],
          ),
        );

      case 'category':
        return LayoutSection(
          id: id,
          builder: (_) => HomeSections.categories(
            items: [
              for (final category in data.categories)
                CategoryItem(
                  id: category.id.toString(),
                  title: category.name,
                  imageUrl: category.image,
                ),
            ],
            onTap: (category) => Navigator.pushNamed(
              context,
              AppRoutes.products,
              arguments: {
                'category_id': int.tryParse(category.id),
                'title': category.title,
              },
            ),
          ),
        );

      case 'special_offer':
        return LayoutSection(
          id: id,
          builder: (_) => specialOffers.isEmpty
              ? const SizedBox.shrink()
              : HomeSections.specialOffers(
                  products: specialOffers,
                  onProductTap: (item) => Navigator.pushNamed(
                    context,
                    AppRoutes.productDetail,
                    arguments: int.tryParse(item.id) ?? 0,
                  ),
                ),
        );

      case 'product_grid':
        return LayoutSection(
          id: id,
          builder: (_) {
            if (products.isEmpty) {
              return const EmptyStateComponent(
                title: 'محصولی برای نمایش وجود ندارد',
              );
            }

            return LayoutBuilder(
              builder: (context, constraints) {
                final columns = constraints.maxWidth >= 1100
                    ? 5
                    : constraints.maxWidth >= 800
                        ? 4
                        : constraints.maxWidth >= 560
                            ? 3
                            : 2;

                return HomeSections.products(
                  products: products,
                  title: 'جدیدترین محصولات',
                  columns: columns,
                  onProductTap: (item) => Navigator.pushNamed(
                    context,
                    AppRoutes.productDetail,
                    arguments: int.tryParse(item.id) ?? 0,
                  ),
                );
              },
            );
          },
        );

      // These sections already exist in the JSON contract. They stay harmlessly
      // skippable until their corresponding Home data is wired to the API.
      case 'brand':
      case 'review':
      case 'footer':
      case 'bottom_navigation':
        return LayoutSection(
          id: id,
          builder: (_) => const SizedBox.shrink(),
        );

      default:
        return LayoutSection(
          id: id,
          builder: (_) => const SizedBox.shrink(),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final home = ref.watch(homeProvider);

    return Scaffold(
      body: home.when(
        loading: () => const LoadingComponent(
          message: 'در حال بارگذاری فروشگاه...',
        ),
        error: (error, _) => ErrorStateComponent(
          title: 'بارگذاری خانه انجام نشد',
          message: error.toString(),
          actionLabel: 'تلاش مجدد',
          onAction: () => ref.invalidate(homeProvider),
        ),
        data: (data) {
          final products = [
            for (final product in data.products) _productItem(product),
          ];
          final specialOffers = products
              .where(
                (product) =>
                    product.discountPrice != null &&
                    product.discountPrice! < product.price,
              )
              .take(10)
              .toList();

          return FutureBuilder<List<String>>(
            future: _layoutFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const LoadingComponent(
                  message: 'در حال آماده‌سازی چیدمان فروشگاه...',
                );
              }

              if (snapshot.hasError) {
                return ErrorStateComponent(
                  title: 'چیدمان خانه بارگذاری نشد',
                  message: snapshot.error.toString(),
                  actionLabel: 'استفاده از چیدمان پیش‌فرض',
                  onAction: () {
                    setState(() {
                      _layoutFuture = Future.value(const [
                        'header',
                        'search',
                        'banner',
                        'category',
                        'special_offer',
                        'product_grid',
                      ]);
                    });
                  },
                );
              }

              final ids = snapshot.data ?? const <String>[];
              final sections = [
                for (final id in ids)
                  _buildSection(
                    context,
                    id,
                    products,
                    specialOffers,
                    data,
                  ),
              ];

              return RefreshIndicator(
                onRefresh: () async => ref.invalidate(homeProvider),
                child: ConfigurableLayout(
                  padding: const EdgeInsets.only(bottom: 24),
                  sections: sections,
                ),
              );
            },
          );
        },
      ),
      bottomNavigationBar: BottomNavigationComponent(
        currentIndex: 0,
        items: const [
          BottomNavigationItem(
            label: 'خانه',
            icon: Icons.home_outlined,
            activeIcon: Icons.home,
          ),
          BottomNavigationItem(
            label: 'محصولات',
            icon: Icons.grid_view_outlined,
          ),
          BottomNavigationItem(
            label: 'سبد',
            icon: Icons.shopping_cart_outlined,
          ),
          BottomNavigationItem(
            label: 'سفارش‌ها',
            icon: Icons.receipt_long_outlined,
          ),
          BottomNavigationItem(
            label: 'حساب',
            icon: Icons.person_outline,
          ),
        ],
        onTap: (index) {
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
      ),
    );
  }
}
