import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/models/order_model.dart';
import '../../../providers/store_providers.dart';
import '../../../shared/widgets/store_widgets.dart';


class OrderDetailScreen extends ConsumerStatefulWidget {
  const OrderDetailScreen({
    super.key,
    required this.orderId,
  });

  final int orderId;


  @override
  ConsumerState<OrderDetailScreen> createState() =>
      _OrderDetailScreenState();
}



class _OrderDetailScreenState
    extends ConsumerState<OrderDetailScreen> {

  bool busy = false;


  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title: const Text('جزئیات سفارش'),
      ),


      body: FutureBuilder<OrderModel>(

        future: ref
            .read(storeRepositoryProvider)
            .getOrder(widget.orderId),


        builder: (context, snapshot) {


          if (snapshot.connectionState !=
              ConnectionState.done) {

            return const Center(
              child: CircularProgressIndicator(),
            );
          }


          if (snapshot.hasError) {

            return Center(
              child: Text(
                snapshot.error.toString(),
              ),
            );
          }


          final order = snapshot.data!;


          return ListView(

            padding:
                const EdgeInsets.all(14),


            children: [


              Card(

                child: Padding(

                  padding:
                      const EdgeInsets.all(16),


                  child: Column(

                    crossAxisAlignment:
                        CrossAxisAlignment.start,


                    children: [

                      Text(

                        order.orderNumber,

                        style:
                            const TextStyle(
                          fontWeight:
                              FontWeight.bold,

                          fontSize:
                              18,
                        ),
                      ),


                      const SizedBox(
                        height: 12,
                      ),


                      Row(

                        children: [

                          StatusChip(

                            label:
                                orderStatusLabel(
                                  order.orderStatus,
                                ),

                            color:
                                order.orderStatus ==
                                        'cancelled'
                                    ? Colors.red
                                    : Colors.blue,
                          ),


                          const SizedBox(
                            width: 8,
                          ),


                          StatusChip(

                            label:
                                paymentStatusLabel(
                                  order.paymentStatus,
                                ),

                            color:
                                order.paymentStatus ==
                                        'paid'
                                    ? Colors.green
                                    : Colors.orange,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),



              if (order.addressSnapshot != null)

                Card(

                  child: ListTile(

                    leading:
                        const Icon(
                      Icons.location_on_outlined,
                    ),


                    title:
                        Text(
                      order.addressSnapshot!['title']
                              ?.toString() ??
                          'آدرس ارسال',
                    ),


                    subtitle:
                        Text(

                      '${order.addressSnapshot!['receiver_name'] ?? ''}\n'
                      '${order.addressSnapshot!['province'] ?? ''}، '
                      '${order.addressSnapshot!['city'] ?? ''}، '
                      '${order.addressSnapshot!['address'] ?? ''}',
                    ),
                  ),
                ),



              const SizedBox(
                height: 8,
              ),



              const Text(

                'اقلام سفارش',

                style:
                    TextStyle(
                  fontSize: 18,
                  fontWeight:
                      FontWeight.bold,
                ),
              ),



              const SizedBox(
                height: 8,
              ),



              ...order.items.map(

                (item) => Card(

                  child: ListTile(

                    title:
                        Text(
                      item.productName,
                    ),


                    subtitle:
                        Text(
                      '${item.quantity} عدد × '
                      '${money(item.unitPrice)} تومان',
                    ),


                    trailing:
                        Text(
                      '${money(item.lineTotal)} تومان',
                    ),
                  ),
                ),
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
                            'جمع کالاها',
                          ),

                          const Spacer(),


                          Text(
                            '${money(order.subtotal)} تومان',
                          ),
                        ],
                      ),



                      Row(

                        children: [

                          const Text(
                            'تخفیف',
                          ),

                          const Spacer(),


                          Text(
                            '${money(order.discountTotal)} تومان',
                          ),
                        ],
                      ),



                      Row(

                        children: [

                          const Text(
                            'ارسال',
                          ),

                          const Spacer(),


                          Text(
                            '${money(order.shippingTotal)} تومان',
                          ),
                        ],
                      ),



                      const Divider(),



                      Row(

                        children: [

                          const Text(

                            'مبلغ نهایی',

                            style:
                                TextStyle(
                              fontWeight:
                                  FontWeight.bold,
                            ),
                          ),


                          const Spacer(),


                          Text(

                            '${money(order.total)} تومان',

                            style:
                                const TextStyle(
                              fontWeight:
                                  FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),



              if (order.orderStatus == 'pending' ||
                  order.orderStatus == 'confirmed')

                Padding(

                  padding:
                      const EdgeInsets.only(
                    top: 12,
                  ),


                  child: OutlinedButton.icon(

                    onPressed:
                        busy
                            ? null
                            : () => _cancel(order.id),


                    icon:
                        const Icon(
                      Icons.cancel_outlined,
                    ),


                    label:
                        const Text(
                      'لغو سفارش',
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }



  Future<void> _cancel(int id) async {

    setState(() {
      busy = true;
    });


    try {

      await ref
          .read(storeRepositoryProvider)
          .cancelOrder(id);


      if (mounted) {

        ScaffoldMessenger.of(context)
            .showSnackBar(

          const SnackBar(
            content:
                Text(
              'سفارش لغو شد',
            ),
          ),
        );


        ref.invalidate(
          ordersProvider,
        );
      }


    } catch (error) {

      if (mounted) {

        ScaffoldMessenger.of(context)
            .showSnackBar(

          SnackBar(
            content:
                Text(
              error.toString(),
            ),
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
  }
}