import 'model_helpers.dart';
import 'product_model.dart';

class CartItemModel {
  const CartItemModel({required this.id, required this.product, required this.variantId, required this.quantity, required this.price});
  final int id;
  final ProductModel product;
  final int? variantId;
  final int quantity;
  final num price;
  num get lineTotal => price * quantity;
  factory CartItemModel.fromJson(Map<String, dynamic> json) => CartItemModel(
        id: asInt(json['id']), product: ProductModel.fromJson(asMap(json['product'])),
        variantId: json['variant_id'] == null ? (json['product_variant_id'] == null ? null : asInt(json['product_variant_id'])) : asInt(json['variant_id']),
        quantity: asInt(json['quantity'], 1), price: asDouble(json['price']) ?? 0,
      );
}

class CartModel {
  const CartModel({required this.id, required this.items});
  final int? id;
  final List<CartItemModel> items;
  num get estimatedSubtotal => items.fold<num>(0, (sum, item) => sum + item.lineTotal);
  factory CartModel.fromJson(Map<String, dynamic> json) => CartModel(id: json['id'] == null ? null : asInt(json['id']), items: asList(json['items']).map((item) => CartItemModel.fromJson(asMap(item))).toList());
}
