class Category {
  final int id;
  final int? parentId;
  final String name;
  final String slug;
  final String? description;
  final String? image;
  final int sortOrder;
  final bool isActive;
  final List<Category> children;

  Category({
    required this.id,
    required this.parentId,
    required this.name,
    required this.slug,
    required this.description,
    required this.image,
    required this.sortOrder,
    required this.isActive,
    required this.children,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'] as int,
      parentId: json['parent_id'] as int?,
      name: json['name'] as String,
      slug: json['slug'] as String,
      description: json['description'] as String?,
      image: json['image'] as String?,
      sortOrder: json['sort_order'] as int,
      isActive: json['is_active'] as bool,
      children: (json['children'] as List<dynamic>? ?? [])
          .map(
            (child) => Category.fromJson(
              child as Map<String, dynamic>,
            ),
          )
          .toList(),
    );
  }
}