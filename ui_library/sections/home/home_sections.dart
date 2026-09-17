import 'package:flutter/material.dart';

import '../../components/banner/banner.dart';
import '../../components/brand/brand.dart';
import '../../components/category/category.dart';
import '../../components/product_card/product_card.dart';
import '../../components/product_grid/product_grid.dart';
import '../../components/review/review.dart';
import '../../components/special_offer/special_offer.dart';

/// Reusable Home sections. Data, navigation and business rules stay in the page.
class HomeSections {
  const HomeSections._();

  static Widget banner({
    required List<BannerItem> items,
    ValueChanged<BannerItem>? onTap,
  }) {
    return BannerComponent(items: items, onTap: onTap);
  }

  static Widget categories({
    required List<CategoryItem> items,
    ValueChanged<CategoryItem>? onTap,
    String title = 'دسته‌بندی‌ها',
  }) {
    return CategoryComponent(items: items, onTap: onTap, showTitle: true, title: title);
  }

  static Widget specialOffers({
    required List<ProductCardItem> products,
    ValueChanged<ProductCardItem>? onProductTap,
    ValueChanged<ProductCardItem>? onAddToCart,
    ValueChanged<ProductCardItem>? onFavoriteTap,
  }) {
    return SpecialOfferComponent(
      products: products,
      onProductTap: onProductTap,
      onAddToCart: onAddToCart,
      onFavoriteTap: onFavoriteTap,
    );
  }

  static Widget products({
    required List<ProductCardItem> products,
    ValueChanged<ProductCardItem>? onProductTap,
    ValueChanged<ProductCardItem>? onAddToCart,
    ValueChanged<ProductCardItem>? onFavoriteTap,
    String title = 'پیشنهادها',
    int columns = 2,
  }) {
    return ProductGridComponent(
      products: products,
      title: title,
      columns: columns,
      onProductTap: onProductTap,
      onAddToCart: onAddToCart,
      onFavoriteTap: onFavoriteTap,
    );
  }

  static Widget brands({
    required List<BrandItem> items,
    ValueChanged<BrandItem>? onTap,
    String title = 'برندهای محبوب',
  }) {
    return BrandComponent(items: items, title: title, onTap: onTap);
  }

  static Widget reviews({
    required List<ReviewItem> reviews,
    ValueChanged<ReviewItem>? onReviewTap,
    VoidCallback? onViewAll,
  }) {
    return ReviewComponent(
      reviews: reviews,
      onReviewTap: onReviewTap,
      onViewAll: onViewAll,
    );
  }
}
