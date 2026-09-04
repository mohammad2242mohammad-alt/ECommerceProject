import 'model_helpers.dart';

class ReviewModel {
  const ReviewModel({required this.id, required this.rating, required this.title, required this.body, required this.status, required this.userName});
  final int id;
  final int rating;
  final String? title;
  final String body;
  final String? status;
  final String userName;
  factory ReviewModel.fromJson(Map<String, dynamic> json) => ReviewModel(id: asInt(json['id']), rating: asInt(json['rating']), title: json['title']?.toString(), body: json['body']?.toString() ?? '', status: json['status']?.toString(), userName: asMap(json['user'])['name']?.toString() ?? 'خریدار');
}
