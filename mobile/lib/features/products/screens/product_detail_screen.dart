import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/routes/app_routes.dart';
import '../../../data/models/product_detail_model.dart';
import '../../../providers/store_providers.dart';
import '../../../shared/widgets/store_widgets.dart';

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
            _Gallery(images: product.images),

            const SizedBox(height: 18),

            Text(
              product.name,
              style: Theme.of(context)
                  .textTheme
                  .headlineSmall
                  ?.copyWith(fontWeight: FontWeight.w900),
            ),

            if (product.shortDescription?.isNotEmpty == true)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  product.shortDescription!,
                  style: const TextStyle(
                    color: Colors.black54,
                    height: 1.6,
                  ),
                ),
              ),

            const SizedBox(height: 12),
                        Row(
              children: [
                const Icon(Icons.star, size: 19, color: Colors.amber),
                Text(
                  ' ${(product.ratingAverage ?? 0).toStringAsFixed(1)} '
                  '(${product.ratingCount ?? 0} نظر)',
                ),
                const Spacer(),
                Text(
                  product.stock > 0 ? 'موجود در انبار' : 'ناموجود',
                  style: TextStyle(
                    color: product.stock > 0 ? Colors.green : Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),

            const Divider(height: 32),

            if (product.variants.isNotEmpty) ...[
              const Text(
                'انتخاب تنوع',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 17,
                ),
              ),

              const SizedBox(height: 10),

              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: product.variants.map((variant) {
                  return ChoiceChip(
                    selected: _variantId == variant.id,
                    onSelected: variant.stock > 0
                        ? (_) => setState(() => _variantId = variant.id)
                        : null,
                    label: Text(_variantLabel(variant)),
                  );
                }).toList(),
              ),

              const Divider(height: 32),
            ],

            if (product.specifications.isNotEmpty) ...[
              const Text(
                'مشخصات',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 17,
                ),
              ),

              const SizedBox(height: 8),

              ...product.specifications.map((spec) {
                final index = product.specifications.indexOf(spec);

                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 11,
                  ),
                  color: index.isEven
                      ? Colors.grey.shade100
                      : Colors.white,

                  child: Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: Text(
                          spec.name,
                          style: const TextStyle(
                            color: Colors.black54,
                          ),
                        ),
                      ),

                      Expanded(
                        flex: 3,
                        child: Text(
                          spec.value,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }),

              const Divider(height: 32),
            ],

            if (product.description?.isNotEmpty == true) ...[
              const Text(
                'معرفی محصول',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 17,
                ),
              ),

              const SizedBox(height: 8),

              Text(
                product.description!,
                style: const TextStyle(height: 1.8),
              ),

              const Divider(height: 32),
            ],

            _Reviews(productId: widget.productId),
          ],
        ),
      ),

      bottomSheet: detailValue == null
          ? null
          : SafeArea(
              child: Container(
                padding: const EdgeInsets.fromLTRB(
                  16,
                  10,
                  16,
                  12,
                ),

                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(.08),
                      blurRadius: 12,
                    ),
                  ],
                ),

                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment:
                            CrossAxisAlignment.start,

                        children: [
                          if (detailValue.hasDiscount)
                            Text(
                              '${money(detailValue.price)} تومان',
                              style: const TextStyle(
                                decoration:
                                    TextDecoration.lineThrough,
                                color: Colors.grey,
                              ),
                            ),

                          Text(
                            '${money(_selectedPrice(detailValue))} تومان',
                            style: TextStyle(
                              color: Theme.of(context)
                                  .colorScheme
                                  .primary,
                              fontWeight: FontWeight.w900,
                              fontSize: 17,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(width: 12),

                    Expanded(
                      child: FilledButton(
                        onPressed:
                            detailValue.stock <= 0 || _busy
                                ? null
                                : _addToCart,

                        child: _busy
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child:
                                    CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text(
                                'افزودن به سبد',
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
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

  String _variantLabel(ProductVariantModel variant) {
    final values = variant.values
        .map((value) => '${value.name}: ${value.value}')
        .join('، ');

    return values.isEmpty
        ? (variant.sku ?? 'تنوع ${variant.id}')
        : values;
  }
}
class _Gallery extends StatelessWidget {
  const _Gallery({required this.images});

  final List<ProductImageModel> images;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 300,

      child: images.isEmpty
          ? const NetworkImageBox(
              height: 300,
              width: double.infinity,
              fit: BoxFit.contain,
            )

          : PageView.builder(
              itemCount: images.length,

              itemBuilder: (_, index) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),

                  child: NetworkImageBox(
                    url: images[index].url,
                    height: 300,
                    width: double.infinity,
                    fit: BoxFit.contain,
                  ),
                );
              },
            ),
    );
  }
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
