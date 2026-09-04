import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/routes/app_routes.dart';
import '../../../data/models/home_model.dart';
import '../../../providers/store_providers.dart';
import '../../../shared/widgets/store_widgets.dart';
import '../widgets/product_card.dart';

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
        Padding(padding: const EdgeInsets.fromLTRB(12, 8, 12, 4), child: Row(children: [
          Expanded(child: TextField(controller: _search, textInputAction: TextInputAction.search, onSubmitted: (_) => setState(() => _page = 1), decoration: const InputDecoration(hintText: 'جستجوی محصول', prefixIcon: Icon(Icons.search)))),
          const SizedBox(width: 8),
          PopupMenuButton<String>(icon: const Icon(Icons.sort), tooltip: 'مرتب‌سازی', initialValue: _sort, onSelected: (value) => setState(() { _sort = value; _page = 1; }), itemBuilder: (_) => const [PopupMenuItem(value: 'newest', child: Text('جدیدترین')), PopupMenuItem(value: 'price_asc', child: Text('ارزان‌ترین')), PopupMenuItem(value: 'price_desc', child: Text('گران‌ترین')), PopupMenuItem(value: 'rating_desc', child: Text('بالاترین امتیاز'))]),
        ])),
        Expanded(child: products.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => Center(child: Padding(padding: const EdgeInsets.all(24), child: Column(mainAxisSize: MainAxisSize.min, children: [Text(error.toString(), textAlign: TextAlign.center), const SizedBox(height: 12), FilledButton(onPressed: () => ref.invalidate(productsPageProvider(query)), child: const Text('تلاش مجدد'))]))),
          data: (page) => page.items.isEmpty ? const EmptyState(message: 'محصولی پیدا نشد', icon: Icons.search_off) : LayoutBuilder(builder: (context, constraints) {
            final count = constraints.maxWidth >= 1050 ? 5 : constraints.maxWidth >= 800 ? 4 : constraints.maxWidth >= 560 ? 3 : 2;
            return Column(children: [
              Expanded(child: GridView.builder(padding: const EdgeInsets.all(12), itemCount: page.items.length, gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: count, childAspectRatio: .62, crossAxisSpacing: 10, mainAxisSpacing: 10), itemBuilder: (context, index) {
                final product = page.items[index];
                return ProductCard(product: product, onTap: () => Navigator.pushNamed(context, AppRoutes.productDetail, arguments: product.id));
              })),
              if (page.lastPage > 1) SafeArea(top: false, child: Padding(padding: const EdgeInsets.all(8), child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [IconButton(onPressed: _page > 1 ? () => setState(() => _page--) : null, icon: const Icon(Icons.chevron_right)), Text('صفحه ${page.currentPage} از ${page.lastPage}'), IconButton(onPressed: page.hasNext ? () => setState(() => _page++) : null, icon: const Icon(Icons.chevron_left))]))),
            ]);
          }),
        )),
      ]),
    );
  }
}
