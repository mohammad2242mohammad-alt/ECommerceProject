import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/models/address_model.dart';
import '../data/models/cart_model.dart';
import '../data/models/category_model.dart';
import '../data/models/home_model.dart';
import '../data/models/order_model.dart';
import '../data/models/product_detail_model.dart';
import '../data/models/product_model.dart';
import '../data/models/review_model.dart';
import '../data/repositories/store_repository.dart';
import 'core_providers.dart';


final storeRepositoryProvider =
    Provider<StoreRepository>(
  (ref) => StoreRepository(
    ref.watch(apiClientProvider),
    ref.watch(localStorageProvider),
  ),
);


// جایگزین StateProvider
class AuthUserNotifier extends Notifier<UserModel?> {
  @override
  UserModel? build() {
    return null;
  }

  void setUser(UserModel? user) {
    state = user;
  }
}


final authUserProvider =
    NotifierProvider<AuthUserNotifier, UserModel?>(
  AuthUserNotifier.new,
);



final homeProvider =
    FutureProvider<HomeModel>(
  (ref) =>
      ref.watch(storeRepositoryProvider).getHome(),
);



final allCategoriesProvider =
    FutureProvider<List<Category>>(
  (ref) =>
      ref.watch(storeRepositoryProvider).getCategories(),
);



final productsPageProvider =
    FutureProvider.family<ProductsPage, ProductQuery>(
  (ref, query) =>
      ref.watch(storeRepositoryProvider).getProducts(query),
);



final productDetailProvider =
    FutureProvider.family<ProductDetailModel, int>(
  (ref, id) =>
      ref.watch(storeRepositoryProvider).getProduct(id),
);



final productReviewsProvider =
    FutureProvider.family<List<ReviewModel>, int>(
  (ref, id) =>
      ref.watch(storeRepositoryProvider).getReviews(id),
);



final cartProvider =
    FutureProvider<CartModel?>(
  (ref) =>
      ref.watch(storeRepositoryProvider).getCart(),
);



final addressesProvider =
    FutureProvider<List<AddressModel>>(
  (ref) =>
      ref.watch(storeRepositoryProvider).getAddresses(),
);



final ordersProvider =
    FutureProvider<List<OrderModel>>(
  (ref) =>
      ref.watch(storeRepositoryProvider).getOrders(),
);



final favoritesProvider =
    FutureProvider<List<ProductModel>>(
  (ref) =>
      ref.watch(storeRepositoryProvider).getFavorites(),
);