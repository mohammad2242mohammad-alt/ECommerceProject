import 'model_helpers.dart';

class AddressModel {
  const AddressModel({required this.id, required this.title, required this.receiverName, required this.receiverPhone, required this.province, required this.city, required this.address, required this.postalCode, required this.latitude, required this.longitude, required this.isDefault});
  final int id;
  final String title;
  final String receiverName;
  final String receiverPhone;
  final String province;
  final String city;
  final String address;
  final String postalCode;
  final double? latitude;
  final double? longitude;
  final bool isDefault;
  factory AddressModel.fromJson(Map<String, dynamic> json) => AddressModel(id: asInt(json['id']), title: json['title']?.toString() ?? '', receiverName: json['receiver_name']?.toString() ?? '', receiverPhone: json['receiver_phone']?.toString() ?? '', province: json['province']?.toString() ?? '', city: json['city']?.toString() ?? '', address: json['address']?.toString() ?? '', postalCode: json['postal_code']?.toString() ?? '', latitude: asDouble(json['latitude']), longitude: asDouble(json['longitude']), isDefault: asBool(json['is_default']));
}
