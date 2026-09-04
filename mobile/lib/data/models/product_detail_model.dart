import 'model_helpers.dart';
import 'product_model.dart';

class ProductImageModel {
  const ProductImageModel({required this.id, required this.url, required this.isPrimary, this.altText});
  final int id;
  final String url;
  final bool isPrimary;
  final String? altText;
  factory ProductImageModel.fromJson(Map<String, dynamic> json) => ProductImageModel(id: asInt(json['id']), url: json['url']?.toString() ?? json['path']?.toString() ?? '', isPrimary: asBool(json['is_primary']), altText: json['alt_text']?.toString());
}

class ProductSpecification {
  const ProductSpecification({required this.name, required this.value});
  final String name;
  final String value;
  factory ProductSpecification.fromJson(Map<String, dynamic> json) => ProductSpecification(name: json['name']?.toString() ?? '', value: json['value']?.toString() ?? '');
}

class ProductVariantModel {
  const ProductVariantModel({required this.id, required this.sku, required this.price, required this.discountPrice, required this.stock, required this.status, required this.values});
  final int id;
  final String? sku;
  final num? price;
  final num? discountPrice;
  final int stock;
  final String? status;
  final List<ProductSpecification> values;
  num get currentPrice => discountPrice ?? price ?? 0;
  factory ProductVariantModel.fromJson(Map<String, dynamic> json) => ProductVariantModel(id: asInt(json['id']), sku: json['sku']?.toString(), price: asDouble(json['price']), discountPrice: asDouble(json['discount_price']), stock: asInt(json['stock']), status: json['status']?.toString(), values: asList(json['values']).map((item) => ProductSpecification.fromJson(asMap(item))).toList());
}

class ProductDetailModel extends ProductModel {
  const ProductDetailModel({required super.id, required super.categoryId, required super.name, required super.slug, required super.sku, required super.shortDescription, required super.description, required super.price, required super.discountPrice, required super.stock, required super.status, required super.ratingAverage, required super.ratingCount, required super.category, required super.image, required this.images, required this.specifications, required this.variants});
  final List<ProductImageModel> images;
  final List<ProductSpecification> specifications;
  final List<ProductVariantModel> variants;
  factory ProductDetailModel.fromJson(Map<String, dynamic> json) {
    final product = ProductModel.fromJson(json);
    return ProductDetailModel(
      id: product.id, categoryId: product.categoryId, name: product.name, slug: product.slug, sku: product.sku,
      shortDescription: product.shortDescription, description: product.description, price: product.price,
      discountPrice: product.discountPrice, stock: product.stock, status: product.status, ratingAverage: product.ratingAverage,
      ratingCount: product.ratingCount, category: product.category, image: product.image,
      images: asList(json['images']).map((item) => ProductImageModel.fromJson(asMap(item))).toList(),
      specifications: asList(json['specifications']).map((item) => ProductSpecification.fromJson(asMap(item))).toList(),
      variants: asList(json['variants']).map((item) => ProductVariantModel.fromJson(asMap(item))).toList(),
    );
  }
}
