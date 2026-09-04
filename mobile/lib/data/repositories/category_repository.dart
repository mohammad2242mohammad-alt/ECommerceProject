import '../models/category_model.dart';
import '../services/category_service.dart';

class CategoryRepository {
  CategoryRepository({CategoryService? categoryService})
      : _categoryService = categoryService ?? CategoryService();

  final CategoryService _categoryService;

  Future<List<Category>> getCategories() {
    return _categoryService.getCategories();
  }
}
