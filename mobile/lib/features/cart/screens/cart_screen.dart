import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/routes/app_routes.dart';
import '../../../providers/store_providers.dart';
import '../../../shared/widgets/store_widgets.dart';


class CartScreen extends ConsumerWidget {

  const CartScreen({
    super.key,
  });


  @override
  Widget build(
    BuildContext context,
    WidgetRef ref,
  ) {

    if (ref.watch(authUserProvider) == null) {
      return _LoginRequired(
        onLogin: () {
          Navigator.pushNamed(
            context,
            AppRoutes.auth,
          );
        },
      );
    }


    final cart = ref.watch(cartProvider);


    return Scaffold(

      appBar: AppBar(
        title: const Text(
          'سبد خرید',
        ),
      ),


      body: cart.when(

        loading: () =>
            const Center(
              child: CircularProgressIndicator(),
            ),


        error: (
          error,
          _,
        ) =>
            Center(

              child: Column(

                mainAxisSize:
                    MainAxisSize.min,

                children: [

                  Text(
                    error.toString(),
                  ),


                  FilledButton(

                    onPressed: () =>
                        ref.invalidate(
                          cartProvider,
                        ),

                    child:
                        const Text(
                      'تلاش مجدد',
                    ),
                  ),
                ],
              ),
            ),



        data: (
          value,
        ) {


          if (value == null ||
              value.items.isEmpty) {

            return const EmptyState(
              message:
                  'سبد خرید شما خالی است',

              icon:
                  Icons.shopping_cart_outlined,
            );
          }



          return ListView(

            padding:
                const EdgeInsets.all(14),


            children: [

              ...value.items.map(
                (
                  item,
                ) {


                  return Card(

                    child: Padding(

                      padding:
                          const EdgeInsets.all(10),


                      child: Row(

                        children: [

                          NetworkImageBox(

                            url:
                                item.product.image,

                            width:
                                82,

                            height:
                                82,

                            fit:
                                BoxFit.contain,
                          ),


                          const SizedBox(
                            width: 10,
                          ),



                          Expanded(

                            child: Column(

                              crossAxisAlignment:
                                  CrossAxisAlignment.start,


                              children: [


                                Text(

                                  item.product.name,

                                  maxLines:
                                      2,

                                  overflow:
                                      TextOverflow.ellipsis,


                                  style:
                                      const TextStyle(
                                    fontWeight:
                                        FontWeight.bold,
                                  ),
                                ),



                                const SizedBox(
                                  height: 6,
                                ),



                                Text(
                                  '${money(item.price)} تومان',
                                ),



                                const SizedBox(
                                  height: 8,
                                ),



                                Row(

                                  children: [


                                    IconButton(

                                      onPressed:
                                          item.quantity > 1

                                              ? () async {

                                                  await _update(
                                                    ref,
                                                    item.id,
                                                    item.quantity - 1,
                                                  );

                                                }

                                              : null,


                                      icon:
                                          const Icon(
                                        Icons.remove_circle_outline,
                                      ),
                                    ),



                                    Text(
                                      '${item.quantity}',
                                    ),



                                    IconButton(

                                      onPressed:
                                          item.quantity < 100

                                              ? () async {

                                                  await _update(
                                                    ref,
                                                    item.id,
                                                    item.quantity + 1,
                                                  );

                                                }

                                              : null,


                                      icon:
                                          const Icon(
                                        Icons.add_circle_outline,
                                      ),
                                    ),



                                    const Spacer(),



                                    IconButton(

                                      onPressed:
                                          () async {

                                        await ref
                                            .read(
                                              storeRepositoryProvider,
                                            )
                                            .deleteCartItem(
                                              item.id,
                                            );


                                        ref.invalidate(
                                          cartProvider,
                                        );
                                      },


                                      icon:
                                          const Icon(
                                        Icons.delete_outline,
                                        color:
                                            Colors.red,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),



              const SizedBox(
                height: 10,
              ),



              Card(

                child: Padding(

                  padding:
                      const EdgeInsets.all(16),


                  child: Column(

                    children: [


                      Row(

                        children: [

                          const Text(
                            'جمع اقلام',
                          ),


                          const Spacer(),


                          Text(
                            '${money(value.estimatedSubtotal)} تومان',
                          ),
                        ],
                      ),



                      const SizedBox(
                        height: 8,
                      ),



                      const Text(

                        'مبلغ نهایی و هزینه ارسال در مرحله پرداخت توسط سرور محاسبه می‌شود.',

                        style:
                            TextStyle(
                          color:
                              Colors.grey,

                          fontSize:
                              12,
                        ),
                      ),



                      const SizedBox(
                        height: 14,
                      ),



                      FilledButton.icon(

                        onPressed:
                            () {

                          Navigator.pushNamed(
                            context,
                            AppRoutes.checkout,
                          );

                        },


                        icon:
                            const Icon(
                          Icons.arrow_back,
                        ),


                        label:
                            const Text(
                          'ادامه و تسویه حساب',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }



  Future<void> _update(
    WidgetRef ref,
    int id,
    int quantity,
  ) async {

    try {

      await ref
          .read(
            storeRepositoryProvider,
          )
          .updateCartItem(
            id,
            quantity,
          );


      ref.invalidate(
        cartProvider,
      );


    } catch (_) {

      // server error will appear after refresh

    }
  }
}



class _LoginRequired extends StatelessWidget {

  const _LoginRequired({
    required this.onLogin,
  });


  final VoidCallback onLogin;



  @override
  Widget build(
    BuildContext context,
  ) {

    return Scaffold(

      appBar:
          AppBar(
        title:
            const Text(
          'سبد خرید',
        ),
      ),


      body:
          Center(

        child:
            Column(

          mainAxisSize:
              MainAxisSize.min,


          children: [


            const Icon(
              Icons.lock_outline,
              size:
                  58,
              color:
                  Colors.grey,
            ),



            const SizedBox(
              height:
                  12,
            ),



            const Text(
              'برای مشاهده سبد خرید ابتدا وارد حساب شوید',
            ),



            const SizedBox(
              height:
                  12,
            ),



            FilledButton(

              onPressed:
                  onLogin,


              child:
                  const Text(
                'ورود / ثبت‌نام',
              ),
            ),
          ],
        ),
      ),
    );
  }
}