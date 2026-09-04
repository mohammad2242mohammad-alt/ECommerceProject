import 'category_model.dart';
import 'model_helpers.dart';

class ProductModel {
  const ProductModel({required this.id, required this.categoryId, required this.name, required this.slug, required this.sku, required this.shortDescription, required this.description, required this.price, required this.discountPrice, required this.stock, required this.status, required this.ratingAverage, required this.ratingCount, required this.category, required this.image});
  final int id;
  final int? categoryId;
  final String name;
  final String slug;
  final String? sku;
  final String? shortDescription;
  final String? description;
  final num price;
  final num? discountPrice;
  final int stock;
  final String? status;
  final double? ratingAverage;
  final int? ratingCount;
  final Category? category;
  final String? image;
  num get currentPrice => discountPrice != null && discountPrice! < price ? discountPrice! : price;
  bool get hasDiscount => discountPrice != null && discountPrice! < price;
  factory ProductModel.fromJson(Map<String, dynamic> json) => ProductModel(
        id: asInt(json['id']),
        categoryId: json['category_id'] == null ? null : asInt(json['category_id']),
        name: json['name']?.toString() ?? '',
        slug: json['slug']?.toString() ?? '',
        sku: json['sku']?.toString(),
        shortDescription: json['short_description']?.toString(),
        description: json['description']?.toString(),
        price: asDouble(json['price']) ?? 0,
        discountPrice: json['discount_price'] == null ? null : asDouble(json['discount_price']),
        stock: asInt(json['stock']),
        status: json['status']?.toString(),
        ratingAverage: asDouble(json['rating_average']),
        ratingCount: json['rating_count'] == null ? null : asInt(json['rating_count']),
        category: json['category'] == null ? null : Category.fromJson(asMap(json['category'])),
        image: json['image']?.toString(),
      );
}
