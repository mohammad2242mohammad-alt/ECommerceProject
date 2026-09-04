import 'model_helpers.dart';

class Category {
  const Category({required this.id, required this.parentId, required this.name, required this.slug, required this.description, required this.image, required this.sortOrder, required this.isActive, required this.children});
  final int id;
  final int? parentId;
  final String name;
  final String slug;
  final String? description;
  final String? image;
  final int sortOrder;
  final bool isActive;
  final List<Category> children;
  factory Category.fromJson(Map<String, dynamic> json) => Category(
        id: asInt(json['id']),
        parentId: json['parent_id'] == null ? null : asInt(json['parent_id']),
        name: json['name']?.toString() ?? '',
        slug: json['slug']?.toString() ?? '',
        description: json['description']?.toString(),
        image: json['image']?.toString(),
        sortOrder: asInt(json['sort_order']),
        isActive: asBool(json['is_active'], true),
        children: asList(json['children']).map((item) => Category.fromJson(asMap(item))).toList(),
      );
}
