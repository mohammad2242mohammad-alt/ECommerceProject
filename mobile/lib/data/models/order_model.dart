import 'model_helpers.dart';

class UserModel {
  const UserModel({required this.id, required this.phone, required this.name, required this.role, required this.isActive});
  final int id;
  final String phone;
  final String? name;
  final String role;
  final bool isActive;
  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(id: asInt(json['id']), phone: json['phone']?.toString() ?? '', name: json['name']?.toString(), role: json['role']?.toString() ?? 'customer', isActive: asBool(json['is_active'], true));
}

class AuthSession {
  const AuthSession({required this.user, required this.token});
  final UserModel user;
  final String token;
}

class OrderItemModel {
  const OrderItemModel({required this.id, required this.productName, required this.sku, required this.unitPrice, required this.discountAmount, required this.quantity, required this.lineTotal});
  final int id;
  final String productName;
  final String? sku;
  final num unitPrice;
  final num discountAmount;
  final int quantity;
  final num lineTotal;
  factory OrderItemModel.fromJson(Map<String, dynamic> json) => OrderItemModel(id: asInt(json['id']), productName: json['product_name_snapshot']?.toString() ?? json['product_name']?.toString() ?? '', sku: json['sku_snapshot']?.toString(), unitPrice: asDouble(json['unit_price'] ?? json['price']) ?? 0, discountAmount: asDouble(json['discount_amount']) ?? 0, quantity: asInt(json['quantity'], 1), lineTotal: asDouble(json['line_total'] ?? json['subtotal']) ?? 0);
}

class PaymentModel {
  const PaymentModel({required this.status, required this.amount, required this.gateway, this.transactionReference});
  final String? status;
  final num amount;
  final String? gateway;
  final String? transactionReference;
  factory PaymentModel.fromJson(Map<String, dynamic> json) => PaymentModel(status: json['status']?.toString(), amount: asDouble(json['amount']) ?? 0, gateway: json['gateway']?.toString(), transactionReference: json['transaction_reference']?.toString());
}

class OrderModel {
  const OrderModel({required this.id, required this.orderNumber, required this.subtotal, required this.discountTotal, required this.shippingTotal, required this.total, required this.paymentStatus, required this.orderStatus, required this.items, this.addressSnapshot, this.payment});
  final int id;
  final String orderNumber;
  final num subtotal;
  final num discountTotal;
  final num shippingTotal;
  final num total;
  final String paymentStatus;
  final String orderStatus;
  final List<OrderItemModel> items;
  final Map<String, dynamic>? addressSnapshot;
  final PaymentModel? payment;
  factory OrderModel.fromJson(Map<String, dynamic> json) => OrderModel(id: asInt(json['id']), orderNumber: json['order_number']?.toString() ?? '#${json['id'] ?? ''}', subtotal: asDouble(json['subtotal']) ?? 0, discountTotal: asDouble(json['discount_total'] ?? json['discount']) ?? 0, shippingTotal: asDouble(json['shipping_total']) ?? 0, total: asDouble(json['total']) ?? 0, paymentStatus: json['payment_status']?.toString() ?? 'unpaid', orderStatus: json['order_status']?.toString() ?? json['status']?.toString() ?? 'pending', items: asList(json['items']).map((item) => OrderItemModel.fromJson(asMap(item))).toList(), addressSnapshot: json['address_snapshot'] is Map ? asMap(json['address_snapshot']) : null, payment: json['payment'] is Map ? PaymentModel.fromJson(asMap(json['payment'])) : null);
}
