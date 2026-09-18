import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/routes/app_routes.dart';
import '../../../data/models/home_model.dart';
import '../../../providers/store_providers.dart';
import '../../../shared/widgets/store_widgets.dart';
import '../widgets/product_ui_components.dart';

class ProductsScreen extends ConsumerStatefulWidget {
  const ProductsScreen({super.key, this.categoryId, this.initialSearch, this.title});
  final int? categoryId;
  final String? initialSearch;
  final String? title;
  @override
  ConsumerState<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends ConsumerState<ProductsScreen> {
  late final TextEditingController _search = TextEditingController(text: widget.initialSearch);
  int _page = 1;
  String _sort = 'newest';
  @override
  void dispose() { _search.dispose(); super.dispose(); }
  ProductQuery get query => ProductQuery(categoryId: widget.categoryId, search: _search.text, page: _page, sort: _sort);

  @override
  Widget build(BuildContext context) {
    final products = ref.watch(productsPageProvider(query));
    return Scaffold(
      appBar: AppBar(title: Text(widget.title ?? 'محصولات')),
      body: Column(children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
          child: Row(
            children: [
              Expanded(
                child: ProductSearchBar(
                  controller: _search,
                  onSubmitted: (_) => setState(() => _page = 1),
                ),
              ),
              const SizedBox(width: 8),
              ProductSortMenu(
                value: _sort,
                onSelected: (value) => setState(() {
                  _sort = value;
                  _page = 1;
                }),
              ),
            ],
          ),
        ),
        Expanded(child: products.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => Center(child: Padding(padding: const EdgeInsets.all(24), child: Column(mainAxisSize: MainAxisSize.min, children: [Text(error.toString(), textAlign: TextAlign.center), const SizedBox(height: 12), FilledButton(onPressed: () => ref.invalidate(productsPageProvider(query)), child: const Text('تلاش مجدد'))]))),
          data: (page) => ProductListSection(
            page: page,
            onProductTap: (product) => Navigator.pushNamed(
              context,
              AppRoutes.productDetail,
              arguments: product.id,
            ),
            onPrevious: _page > 1 ? () => setState(() => _page--) : null,
            onNext: page.hasNext ? () => setState(() => _page++) : null,
          ),
        )),
      ]),
    );
  }
}
