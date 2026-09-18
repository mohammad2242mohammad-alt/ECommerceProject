import 'package:flutter/material.dart';

import '../../../data/models/category_model.dart';
import '../../../data/models/home_model.dart';
import '../../../data/models/product_model.dart';
import '../../../shared/widgets/shared_widgets.dart';
import '../../products/widgets/product_card.dart';

class StoreHeader extends StatelessWidget {
  const StoreHeader({super.key, this.onFavorites, this.onCart});

  final VoidCallback? onFavorites;
  final VoidCallback? onCart;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(24)),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
          child: Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: scheme.primaryContainer,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Icon(Icons.storefront_rounded, color: scheme.onPrimaryContainer),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'فروشگاه اینترنتی',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w900,
                            letterSpacing: -.3,
                          ),
                    ),
                    const SizedBox(height: 3),
                    Row(
                      children: [
                        Icon(Icons.verified_rounded, size: 14, color: scheme.primary),
                        const SizedBox(width: 4),
                        Text(
                          'خرید سریع و مطمئن',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: scheme.onSurfaceVariant,
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              _HeaderAction(icon: Icons.favorite_border_rounded, tooltip: 'علاقه‌مندی‌ها', onPressed: onFavorites),
              const SizedBox(width: 6),
              _HeaderAction(icon: Icons.shopping_bag_outlined, tooltip: 'سبد خرید', onPressed: onCart),
            ],
          ),
        ),
      ),
    );
  }
}

class _HeaderAction extends StatelessWidget {
  const _HeaderAction({required this.icon, required this.tooltip, this.onPressed});

  final IconData icon;
  final String tooltip;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Material(
      color: scheme.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(14),
        child: Tooltip(
          message: tooltip,
          child: Padding(
            padding: const EdgeInsets.all(11),
            child: Icon(icon, size: 21),
          ),
        ),
      ),
    );
  }
}

class StoreSearchBar extends StatelessWidget {
  const StoreSearchBar({super.key, this.onSubmitted});

  final ValueChanged<String>? onSubmitted;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return TextField(
      textInputAction: TextInputAction.search,
      onSubmitted: onSubmitted,
      decoration: InputDecoration(
        hintText: 'جستجو در محصولات، دسته‌ها و برندها',
        hintStyle: TextStyle(color: scheme.onSurfaceVariant, fontWeight: FontWeight.w500),
        prefixIcon: Icon(Icons.search_rounded, color: scheme.primary),
        filled: true,
        fillColor: scheme.surfaceContainerHighest,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: scheme.primary, width: 1.4),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 15),
      ),
    );
  }
}

class HomeHeroBanner extends StatefulWidget {
  const HomeHeroBanner({super.key, required this.items, this.onTap});

  final List<BannerModel> items;
  final ValueChanged<BannerModel>? onTap;

  @override
  State<HomeHeroBanner> createState() => _HomeHeroBannerState();
}

class _HomeHeroBannerState extends State<HomeHeroBanner> {
  final PageController _controller = PageController();
  int _index = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.items.isEmpty) return const SizedBox.shrink();
    final scheme = Theme.of(context).colorScheme;

    return Column(
      children: [
        SizedBox(
          height: 214,
          child: PageView.builder(
            controller: _controller,
            itemCount: widget.items.length,
            onPageChanged: (value) => setState(() => _index = value),
            itemBuilder: (context, index) {
              final banner = widget.items[index];
              return Padding(
                padding: const EdgeInsets.fromLTRB(12, 6, 12, 2),
                child: Card(
                  elevation: 0,
                  clipBehavior: Clip.antiAlias,
                  margin: EdgeInsets.zero,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                  child: InkWell(
                    onTap: widget.onTap == null ? null : () => widget.onTap!(banner),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        NetworkImageBox(url: banner.image, radius: 0, fit: BoxFit.cover),
                        DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Colors.transparent, Colors.black.withValues(alpha: .78)],
                              stops: const [0.38, 1],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ),
                          ),
                        ),
                        PositionedDirectional(
                          start: 18,
                          end: 18,
                          bottom: 16,
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Expanded(
                                child: Text(
                                  banner.title,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 19,
                                    height: 1.25,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ),
                              if (banner.linkType == 'product')
                                Container(
                                  margin: const EdgeInsetsDirectional.only(start: 10),
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                                  decoration: BoxDecoration(
                                    color: scheme.primary,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Text(
                                    'مشاهده',
                                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        if (widget.items.length > 1)
          Padding(
            padding: const EdgeInsets.only(top: 8, bottom: 2),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                widget.items.length,
                (index) => AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  width: index == _index ? 20 : 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: index == _index ? scheme.primary : scheme.outlineVariant,
                    borderRadius: BorderRadius.circular(99),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class CategoryStrip extends StatelessWidget {
  const CategoryStrip({super.key, required this.items, this.onTap});

  final List<Category> items;
  final ValueChanged<Category>? onTap;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const EmptyState(message: 'دسته‌بندی‌ای ثبت نشده');

    return SizedBox(
      height: 126,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final category = items[index];
          return SizedBox(
            width: 88,
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: onTap == null ? null : () => onTap!(category),
              child: Column(
                children: [
                  Container(
                    height: 82,
                    width: 82,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    padding: const EdgeInsets.all(8),
                    child: NetworkImageBox(url: category.image, radius: 12, fit: BoxFit.contain),
                  ),
                  const SizedBox(height: 7),
                  Text(
                    category.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class SectionHeader extends StatelessWidget {
  const SectionHeader({super.key, required this.title, this.onSeeAll});

  final String title;
  final VoidCallback? onSeeAll;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 22, 16, 10),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900),
            ),
          ),
          if (onSeeAll != null) TextButton(onPressed: onSeeAll, child: const Text('مشاهده همه')),
        ],
      ),
    );
  }
}

class ProductGridSection extends StatelessWidget {
  const ProductGridSection({
    super.key,
    required this.products,
    this.onProductTap,
    this.title = 'جدیدترین محصولات',
    this.onSeeAll,
  });

  final List<ProductModel> products;
  final ValueChanged<ProductModel>? onProductTap;
  final String title;
  final VoidCallback? onSeeAll;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SectionHeader(title: title, onSeeAll: onSeeAll),
        if (products.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: EmptyState(message: 'محصولی برای نمایش وجود ندارد'),
          )
        else
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final columns = constraints.maxWidth >= 1100
                    ? 5
                    : constraints.maxWidth >= 800
                        ? 4
                        : constraints.maxWidth >= 560
                            ? 3
                            : 2;
                return GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: products.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: columns,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    childAspectRatio: .62,
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
            ),
          ),
      ],
    );
  }
}

class SpecialOffersSection extends StatelessWidget {
  const SpecialOffersSection({super.key, required this.products, this.onProductTap});

  final List<ProductModel> products;
  final ValueChanged<ProductModel>? onProductTap;

  @override
  Widget build(BuildContext context) {
    if (products.isEmpty) return const SizedBox.shrink();

    return Column(
      children: [
        const SectionHeader(title: 'پیشنهاد ویژه'),
        SizedBox(
          height: 355,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            scrollDirection: Axis.horizontal,
            itemCount: products.length,
            separatorBuilder: (_, __) => const SizedBox(width: 10),
            itemBuilder: (context, index) {
              final product = products[index];
              return SizedBox(
                width: 205,
                child: ProductCard(
                  product: product,
                  onTap: onProductTap == null ? null : () => onProductTap!(product),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class HomeFooter extends StatelessWidget {
  const HomeFooter({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 28, 16, 12),
      child: Column(
        children: [
          Divider(color: Theme.of(context).colorScheme.outlineVariant),
          const SizedBox(height: 10),
          Text(
            'خرید امن و سریع با فروشگاه اینترنتی',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}
