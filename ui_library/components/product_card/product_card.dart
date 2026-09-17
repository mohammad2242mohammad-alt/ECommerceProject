import 'package:flutter/material.dart';

/// Reusable product data model. Pricing and business rules remain outside the UI.
class ProductCardItem {
  final String id;
  final String title;
  final String? imageUrl;
  final int price;
  final int? discountPrice;
  final int? discountPercent;
  final double? rating;
  final int? reviewCount;
  final bool isFavorite;
  final bool isAvailable;

  const ProductCardItem({
    required this.id,
    required this.title,
    this.imageUrl,
    required this.price,
    this.discountPrice,
    this.discountPercent,
    this.rating,
    this.reviewCount,
    this.isFavorite = false,
    this.isAvailable = true,
  });
}

/// Reusable product card. Navigation, cart actions and favorite persistence
/// are intentionally delegated to the parent page through callbacks.
class ProductCardComponent extends StatelessWidget {
  final ProductCardItem product;
  final VoidCallback? onTap;
  final VoidCallback? onFavoriteTap;
  final VoidCallback? onAddToCart;
  final double width;
  final double imageHeight;
  final String currencyLabel;

  const ProductCardComponent({
    super.key,
    required this.product,
    this.onTap,
    this.onFavoriteTap,
    this.onAddToCart,
    this.width = 190,
    this.imageHeight = 175,
    this.currencyLabel = 'تومان',
  });

  String _formatPrice(int value) {
    final text = value.toString();
    final buffer = StringBuffer();
    for (var i = 0; i < text.length; i++) {
      if (i > 0 && (text.length - i) % 3 == 0) buffer.write(',');
      buffer.write(text[i]);
    }
    return buffer.toString();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasDiscount = product.discountPrice != null &&
        product.discountPrice! > 0 &&
        product.discountPrice! < product.price;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: SizedBox(
        width: width,
        child: Card(
          clipBehavior: Clip.antiAlias,
          elevation: 0,
          margin: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
            side: BorderSide(color: theme.colorScheme.outlineVariant),
          ),
          child: InkWell(
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(10, 10, 10, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: imageHeight,
                    child: Stack(
                      children: [
                        Positioned.fill(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(14),
                            child: product.imageUrl == null
                                ? Container(
                                    color: theme.colorScheme.surfaceContainerHighest,
                                    alignment: Alignment.center,
                                    child: Icon(
                                      Icons.image_outlined,
                                      size: 54,
                                      color: theme.colorScheme.onSurfaceVariant,
                                    ),
                                  )
                                : Image.network(
                                    product.imageUrl!,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => Container(
                                      color: theme.colorScheme.surfaceContainerHighest,
                                      alignment: Alignment.center,
                                      child: Icon(
                                        Icons.broken_image_outlined,
                                        size: 48,
                                        color: theme.colorScheme.onSurfaceVariant,
                                      ),
                                    ),
                                  ),
                          ),
                        ),
                        if (product.discountPercent != null &&
                            product.discountPercent! > 0)
                          PositionedDirectional(
                            start: 8,
                            top: 8,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 5,
                              ),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.error,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                '${product.discountPercent}٪',
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: theme.colorScheme.onError,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                          ),
                        if (onFavoriteTap != null)
                          PositionedDirectional(
                            end: 4,
                            top: 4,
                            child: Material(
                              color: theme.colorScheme.surface.withValues(alpha: .92),
                              shape: const CircleBorder(),
                              child: IconButton(
                                onPressed: onFavoriteTap,
                                tooltip: product.isFavorite
                                    ? 'حذف از علاقه‌مندی‌ها'
                                    : 'افزودن به علاقه‌مندی‌ها',
                                icon: Icon(
                                  product.isFavorite
                                      ? Icons.favorite
                                      : Icons.favorite_border,
                                  size: 21,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    product.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      height: 1.45,
                    ),
                  ),
                  const SizedBox(height: 7),
                  if (product.rating != null)
                    Row(
                      children: [
                        Icon(
                          Icons.star_rounded,
                          size: 17,
                          color: theme.colorScheme.secondary,
                        ),
                        const SizedBox(width: 3),
                        Text(
                          product.rating!.toStringAsFixed(1),
                          style: theme.textTheme.labelMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        if (product.reviewCount != null) ...[
                          const SizedBox(width: 4),
                          Text(
                            '(${product.reviewCount})',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ],
                    ),
                  const SizedBox(height: 8),
                  if (hasDiscount)
                    Text(
                      '${_formatPrice(product.price)} $currencyLabel',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        decoration: TextDecoration.lineThrough,
                      ),
                    ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        child: Text(
                          '${_formatPrice(hasDiscount ? product.discountPrice! : product.price)} $currencyLabel',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      if (onAddToCart != null)
                        IconButton.filledTonal(
                          onPressed: product.isAvailable ? onAddToCart : null,
                          tooltip: product.isAvailable
                              ? 'افزودن به سبد خرید'
                              : 'ناموجود',
                          icon: const Icon(Icons.add_shopping_cart, size: 19),
                        ),
                    ],
                  ),
                  if (!product.isAvailable)
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Text(
                        'ناموجود',
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: theme.colorScheme.error,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
