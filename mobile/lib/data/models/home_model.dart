import 'category_model.dart';
import 'model_helpers.dart';
import 'product_model.dart';

class BannerModel {
  const BannerModel({required this.id, required this.title, required this.image, this.linkType, this.linkValue});
  final int id;
  final String title;
  final String? image;
  final String? linkType;
  final String? linkValue;
  factory BannerModel.fromJson(Map<String, dynamic> json) => BannerModel(id: asInt(json['id']), title: json['title']?.toString() ?? '', image: json['image']?.toString(), linkType: json['link_type']?.toString(), linkValue: json['link_value']?.toString());
}

class HomeModel {
  const HomeModel({required this.banners, required this.categories, required this.products});
  final List<BannerModel> banners;
  final List<Category> categories;
  final List<ProductModel> products;
  factory HomeModel.fromJson(Map<String, dynamic> json) => HomeModel(banners: asList(json['banners']).map((item) => BannerModel.fromJson(asMap(item))).toList(), categories: asList(json['categories']).map((item) => Category.fromJson(asMap(item))).toList(), products: asList(json['products']).map((item) => ProductModel.fromJson(asMap(item))).toList());
}

class ProductQuery {
  const ProductQuery({this.categoryId, this.search, this.page = 1, this.perPage = 15, this.sort, this.minPrice, this.maxPrice});
  final int? categoryId;
  final String? search;
  final int page;
  final int perPage;
  final String? sort;
  final int? minPrice;
  final int? maxPrice;
  @override
  bool operator ==(Object other) => other is ProductQuery && other.categoryId == categoryId && other.search == search && other.page == page && other.perPage == perPage && other.sort == sort && other.minPrice == minPrice && other.maxPrice == maxPrice;
  @override
  int get hashCode => Object.hash(categoryId, search, page, perPage, sort, minPrice, maxPrice);
}

class ProductsPage {
  const ProductsPage({required this.items, required this.currentPage, required this.lastPage, required this.total});
  final List<ProductModel> items;
  final int currentPage;
  final int lastPage;
  final int total;
  bool get hasNext => currentPage < lastPage;
  factory ProductsPage.fromJson(Map<String, dynamic> json) {
    final pagination = asMap(json['pagination']);
    return ProductsPage(items: asList(json['items']).map((item) => ProductModel.fromJson(asMap(item))).toList(), currentPage: asInt(pagination['current_page'], 1), lastPage: asInt(pagination['last_page'], 1), total: asInt(pagination['total']));
  }
}
