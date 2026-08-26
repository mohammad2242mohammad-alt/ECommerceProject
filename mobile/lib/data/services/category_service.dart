import '../../core/constants/api_constants.dart';
import '../../core/network/api_client.dart';
import '../models/category_model.dart';

class CategoryService {
  CategoryService({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient();

  final ApiClient _apiClient;

  Future<List<Category>> getCategories() async {
    final response = await _apiClient.get<List<dynamic>>(
      ApiConstants.categories,
    );

    final categoriesJson = response.data;

    if (categoriesJson == null) {
      return [];
    }

    return categoriesJson
        .map(
          (category) => Category.fromJson(
            category as Map<String, dynamic>,
          ),
        )
        .toList();
  }
}
