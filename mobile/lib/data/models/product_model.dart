/// مدل اطلاعات محصول فروشگاه.
class ProductModel {
  final int id;
  final String name;
  final String description;
  final int price;
  final int? discountPrice;
  final String? image;
  final int stock;
  final bool isActive;
  final double rating;
  final int views;
  final int? categoryId;
  final int? brandId;

  const ProductModel({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.discountPrice,
    required this.image,
    required this.stock,
    required this.isActive,
    required this.rating,
    required this.views,
    required this.categoryId,
    required this.brandId,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: int.tryParse(json['id'].toString()) ?? 0,
      name: json['name']?.toString() ?? '',
      description: json['description']?.toString() ?? '',

      price: double.tryParse(
            json['price']?.toString() ?? '',
          )?.toInt() ??
          0,

      discountPrice: json['discount_price'] == null
          ? null
          : double.tryParse(
              json['discount_price'].toString(),
            )?.toInt(),

      image: json['image']?.toString(),

      stock: int.tryParse(
            json['stock'].toString(),
          ) ??
          0,

      isActive: json['is_active'] == true ||
          json['is_active'].toString() == '1',

      rating: double.tryParse(
            json['rating']?.toString() ?? '',
          ) ??
          0.0,

      views: int.tryParse(
            json['views'].toString(),
          ) ??
          0,

      categoryId: json['category_id'] == null
          ? null
          : int.tryParse(
              json['category_id'].toString(),
            ),

      brandId: json['brand_id'] == null
          ? null
          : int.tryParse(
              json['brand_id'].toString(),
            ),
    );
  }
}