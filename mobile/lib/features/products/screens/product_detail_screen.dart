import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/routes/app_routes.dart';
import '../../../data/models/product_detail_model.dart';
import '../../../providers/store_providers.dart';
import '../widgets/product_detail_ui_components.dart';

class ProductDetailScreen extends ConsumerStatefulWidget {
  const ProductDetailScreen({super.key, required this.productId});
  final int productId;

  @override
  ConsumerState<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends ConsumerState<ProductDetailScreen> {
  int? _variantId;
  bool _busy = false;

  Future<bool> _ensureLogin() async {
    if (ref.read(authUserProvider) != null) return true;

    await Navigator.pushNamed(context, AppRoutes.auth);

    return ref.read(authUserProvider) != null;
  }

  Future<void> _addToCart() async {
    if (!await _ensureLogin()) return;

    final detail = ref.read(productDetailProvider(widget.productId)).value;

    if (detail != null && detail.variants.isNotEmpty && _variantId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('ابتدا تنوع محصول را انتخاب کنید')),
      );
      return;
    }

    setState(() => _busy = true);

    try {
      await ref.read(storeRepositoryProvider).addToCart(
        productId: widget.productId,
        variantId: _variantId,
      );

      ref.invalidate(cartProvider);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('محصول به سبد خرید اضافه شد')),
        );
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error.toString())),
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _favorite() async {
    if (!await _ensureLogin()) return;

    try {
      await ref.read(storeRepositoryProvider).addFavorite(widget.productId);

      ref.invalidate(favoritesProvider);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('به علاقه‌مندی‌ها اضافه شد')),
        );
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error.toString())),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final detail = ref.watch(productDetailProvider(widget.productId));

    final detailValue = detail.maybeWhen(
      data: (value) => value,
      orElse: () => null,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('جزئیات محصول'),
        actions: [
          IconButton(
            onPressed: _favorite,
            icon: const Icon(Icons.favorite_border),
          ),
          IconButton(
            onPressed: () => Navigator.pushNamed(context, AppRoutes.cart),
            icon: const Icon(Icons.shopping_cart_outlined),
          ),
        ],
      ),

      body: detail.when(
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),

        error: (error, _) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(error.toString()),
              const SizedBox(height: 12),
              FilledButton(
                onPressed: () => ref.invalidate(
                  productDetailProvider(widget.productId),
                ),
                child: const Text('تلاش مجدد'),
              ),
            ],
          ),
        ),

        data: (product) => ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 110),
          children: [
            ProductDetailGallery(images: product.images),

            const SizedBox(height: 18),

            ProductDetailHeader(
              name: product.name,
              shortDescription: product.shortDescription,
            ),

            const SizedBox(height: 12),

            ProductDetailRatingStock(
              ratingAverage: product.ratingAverage,
              ratingCount: product.ratingCount,
              stock: product.stock,
            ),

            const Divider(height: 32),

            if (product.variants.isNotEmpty) ...[
              ProductVariantSelector(
                variants: product.variants,
                selectedVariantId: _variantId,
                onChanged: (id) => setState(() => _variantId = id),
              ),

              const Divider(height: 32),
            ],

            if (product.specifications.isNotEmpty) ...[
              ProductSpecificationsSection(
                specifications: product.specifications,
              ),

              const Divider(height: 32),
            ],

            if (product.description?.isNotEmpty == true) ...[
              ProductDescriptionSection(
                description: product.description,
              ),

              const Divider(height: 32),
            ],

            _Reviews(productId: widget.productId),
          ],
        ),
      ),

      bottomSheet: detailValue == null
          ? null
          : ProductDetailBottomBar(
              product: detailValue,
              selectedPrice: _selectedPrice(detailValue),
              busy: _busy,
              onAddToCart: detailValue.stock <= 0 || _busy
                  ? null
                  : _addToCart,
            ),
    );
  }

  num _selectedPrice    );
  }

  num _selectedPrice(ProductDetailModel product) {
    if (_variantId == null) return product.currentPrice;

    final variant = product.variants.firstWhere(
      (item) => item.id == _variantId,
    );

    return variant.currentPrice == 0
        ? product.currentPrice
        : variant.currentPrice;
  }


class _Reviews extends ConsumerWidget {
  const _Reviews({required this.productId});

  final int productId;


  @override
  Widget build(BuildContext context, WidgetRef ref) {

    final reviews = ref.watch(
      productReviewsProvider(productId),
    );


    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,

      children: [

        Row(
          children: [

            const Text(
              'نظر خریداران',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 17,
              ),
            ),

            const Spacer(),

            OutlinedButton.icon(
              onPressed: () async {

                if (ref.read(authUserProvider) == null) {

                  await Navigator.pushNamed(
                    context,
                    AppRoutes.auth,
                  );

                  if (ref.read(authUserProvider) == null) return;
                }


                await showDialog<void>(
                  context: context,

                  builder: (_) => _ReviewDialog(
                    productId: productId,
                  ),
                );


                ref.invalidate(
                  productReviewsProvider(productId),
                );
              },


              icon: const Icon(
                Icons.rate_review_outlined,
              ),

              label: const Text(
                'ثبت نظر',
              ),
            ),
          ],
        ),


        const SizedBox(height: 10),


        reviews.when(

          loading: () => const Center(
            child: CircularProgressIndicator(),
          ),


          error: (error, _) => Text(
            error.toString(),
          ),


          data: (items) {

            if (items.isEmpty) {
              return const Text(
                'هنوز نظری تأیید نشده است.',
                style: TextStyle(
                  color: Colors.grey,
                ),
              );
            }


            return Column(
              children: items.map(
                (review) {

                  return Card(

                    child: ListTile(

                      title: Row(
                        children: [

                          Expanded(
                            child: Text(
                              review.title != null &&
                                      review.title!.isNotEmpty
                                  ? review.title!
                                  : review.userName,
                            ),
                          ),


                          ...List.generate(
                            review.rating,

                            (_) => const Icon(
                              Icons.star,
                              size: 15,
                              color: Colors.amber,
                            ),
                          ),
                        ],
                      ),


                      subtitle: Padding(
                        padding:
                            const EdgeInsets.only(top: 8),

                        child: Text(
                          review.body,
                        ),
                      ),
                    ),
                  );
                },
              ).toList(),
            );
          },
        ),
      ],
    );
  }
}



class _ReviewDialog extends ConsumerStatefulWidget {

  const _ReviewDialog({
    required this.productId,
  });


  final int productId;


  @override
  ConsumerState<_ReviewDialog> createState() =>
      _ReviewDialogState();
}



class _ReviewDialogState
    extends ConsumerState<_ReviewDialog> {


  final title = TextEditingController();
  final body = TextEditingController();

  int rating = 5;
  bool busy = false;


  @override
  void dispose() {
    title.dispose();
    body.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {

    return AlertDialog(

      title: const Text(
        'ثبت نظر',
      ),


      content: SizedBox(

        width: 420,

        child: SingleChildScrollView(

          child: Column(

            mainAxisSize:
                MainAxisSize.min,


            children: [

              DropdownButtonFormField<int>(

                initialValue: rating,

                decoration:
                    const InputDecoration(
                  labelText: 'امتیاز',
                ),


                items: List.generate(
                  5,

                  (index) => DropdownMenuItem(
                    value: index + 1,
                    child:
                        Text('${index + 1} ستاره'),
                  ),
                ),


                onChanged: (value) {
                  setState(() {
                    rating = value ?? 5;
                  });
                },
              ),


              const SizedBox(height: 10),


              TextField(
                controller: title,
                decoration:
                    const InputDecoration(
                  labelText: 'عنوان (اختیاری)',
                ),
              ),


              const SizedBox(height: 10),


              TextField(
                controller: body,
                minLines: 3,
                maxLines: 6,

                decoration:
                    const InputDecoration(
                  labelText: 'متن نظر',
                ),
              ),
            ],
          ),
        ),
      ),


      actions: [

        TextButton(
          onPressed: busy
              ? null
              : () => Navigator.pop(context),

          child:
              const Text('انصراف'),
        ),


        FilledButton(

          onPressed: busy
              ? null
              : () async {

                  if (body.text.trim().isEmpty) return;


                  setState(() {
                    busy = true;
                  });


                  try {

                    await ref
                        .read(storeRepositoryProvider)
                        .submitReview(
                          widget.productId,
                          rating: rating,
                          title: title.text,
                          body: body.text,
                        );


                    if (mounted) {

                      Navigator.pop(context);


                      ScaffoldMessenger.of(context)
                          .showSnackBar(
                        const SnackBar(
                          content: Text(
                            'نظر برای بررسی مدیر ارسال شد',
                          ),
                        ),
                      );
                    }


                  } catch (error) {

                    if (mounted) {

                      ScaffoldMessenger.of(context)
                          .showSnackBar(
                        SnackBar(
                          content:
                              Text(error.toString()),
                        ),
                      );
                    }


                  } finally {

                    if (mounted) {

                      setState(() {
                        busy = false;
                      });
                    }
                  }
                },


          child:
              const Text('ارسال'),
        ),
      ],
    );
  }
}
