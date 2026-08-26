import '../models/product_model.dart';
import '../services/product_service.dart';

class ProductRepository {
  ProductRepository({ProductService? productService})
      : _productService = productService ?? ProductService();

  final ProductService _productService;

  Future<List<ProductModel>> getProducts({
    int? categoryId,
    String? search,
    int? page,
    int? perPage,
    String? sort,
    int? minPrice,
    int? maxPrice,
  }) {
    return _productService.getProducts(
      categoryId: categoryId,
      search: search,
      page: page,
      perPage: perPage,
      sort: sort,
      minPrice: minPrice,
      maxPrice: maxPrice,
    );
  }
}
