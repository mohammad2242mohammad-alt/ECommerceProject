import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/models/product_model.dart';
import '../data/repositories/product_repository.dart';
import '../data/services/product_service.dart';
import 'core_providers.dart';

final productServiceProvider = Provider<ProductService>((ref) {
  final apiClient = ref.watch(apiClientProvider);

  return ProductService(
    apiClient: apiClient,
  );
});

final productRepositoryProvider = Provider<ProductRepository>((ref) {
  final productService = ref.watch(productServiceProvider);

  return ProductRepository(
    productService: productService,
  );
});

/// When [categoryId] is null, all products are returned.
/// When it has a value, only products belonging to that category are loaded.
final productsProvider = FutureProvider.family<List<ProductModel>, int?>(
  (ref, categoryId) {
    final repository = ref.watch(productRepositoryProvider);

    return repository.getProducts(
      categoryId: categoryId,
    );
  },
);
