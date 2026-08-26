import 'category_model.dart';

/// مدل اطلاعات محصول فروشگاه.
class ProductModel {
  final int id;
  final int? categoryId;
  final String name;
  final String slug;
  final String? sku;
  final String? shortDescription;
  final String? description;
  final int price;
  final int? discountPrice;
  final int stock;
  final String? status;
  final double? ratingAverage;
  final int? ratingCount;
  final Category? category;

  const ProductModel({
    required this.id,
    required this.categoryId,
    required this.name,
    required this.slug,
    required this.sku,
    required this.shortDescription,
    required this.description,
    required this.price,
    required this.discountPrice,
    required this.stock,
    required this.status,
    required this.ratingAverage,
    required this.ratingCount,
    required this.category,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: int.tryParse(json['id'].toString()) ?? 0,

      categoryId: json['category_id'] == null
          ? null
          : int.tryParse(json['category_id'].toString()),

      name: json['name']?.toString() ?? '',

      slug: json['slug']?.toString() ?? '',

      sku: json['sku']?.toString(),

      shortDescription: json['short_description']?.toString(),

      description: json['description']?.toString(),

      price: int.tryParse(json['price'].toString()) ?? 0,

      discountPrice: json['discount_price'] == null
          ? null
          : int.tryParse(json['discount_price'].toString()),

      stock: int.tryParse(json['stock'].toString()) ?? 0,

      status: json['status']?.toString(),

      ratingAverage: json['rating_average'] == null
          ? null
          : double.tryParse(
              json['rating_average'].toString(),
            ),

      ratingCount: json['rating_count'] == null
          ? null
          : int.tryParse(
              json['rating_count'].toString(),
            ),

      category: json['category'] == null
          ? null
          : Category.fromJson(
              json['category'] as Map<String, dynamic>,
            ),
    );
  }
}