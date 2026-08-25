import '../../core/constants/api_constants.dart';
import '../../core/network/api_client.dart';
import '../models/product_model.dart';

class ProductService {
  ProductService({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient();

  final ApiClient _apiClient;

  Future<List<ProductModel>> getProducts({
    int? categoryId,
    String? search,
    int? page,
    int? perPage,
    String? sort,
    int? minPrice,
    int? maxPrice,
  }) async {
    final queryParameters = <String, String>{};

    if (categoryId != null) {
      queryParameters['category_id'] = categoryId.toString();
    }

    if (search != null && search.trim().isNotEmpty) {
      queryParameters['search'] = search.trim();
    }

    if (page != null) {
      queryParameters['page'] = page.toString();
    }

    if (perPage != null) {
      queryParameters['per_page'] = perPage.toString();
    }

    if (sort != null && sort.isNotEmpty) {
      queryParameters['sort'] = sort;
    }

    if (minPrice != null) {
      queryParameters['min_price'] = minPrice.toString();
    }

    if (maxPrice != null) {
      queryParameters['max_price'] = maxPrice.toString();
    }

    final response = await _apiClient.get<Map<String, dynamic>>(
      ApiConstants.products,
      queryParameters: queryParameters,
    );

    final data = response.data;

    if (data == null) {
      return [];
    }

    final items = data['items'];

    if (items is! List) {
      return [];
    }

    return items
        .map(
          (item) => ProductModel.fromJson(
            item as Map<String, dynamic>,
          ),
        )
        .toList();
  }
}
