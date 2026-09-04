import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/models/category_model.dart';
import '../data/repositories/category_repository.dart';
import '../data/services/category_service.dart';
import 'core_providers.dart';

final categoryServiceProvider = Provider<CategoryService>((ref) {
  final apiClient = ref.watch(apiClientProvider);

  return CategoryService(
    apiClient: apiClient,
  );
});

final categoryRepositoryProvider =
    Provider<CategoryRepository>((ref) {
  final categoryService = ref.watch(categoryServiceProvider);

  return CategoryRepository(
    categoryService: categoryService,
  );
});

final categoriesProvider =
    FutureProvider<List<Category>>((ref) {
  final repository = ref.watch(categoryRepositoryProvider);

  return repository.getCategories();
});
