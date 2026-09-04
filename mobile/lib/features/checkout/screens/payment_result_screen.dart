import 'package:flutter/material.dart';

import '../../../core/routes/app_routes.dart';
import '../../../data/models/order_model.dart';
import '../../../shared/widgets/store_widgets.dart';


class PaymentResultScreen extends StatelessWidget {

  const PaymentResultScreen({
    super.key,
    required this.order,
  });


  final OrderModel order;


  @override
  Widget build(BuildContext context) {

    final paid =
        order.paymentStatus == 'paid' ||
        order.payment?.status == 'paid';


    return Scaffold(

      body: Center(

        child: Padding(

          padding:
              const EdgeInsets.all(24),


          child: Column(

            mainAxisSize:
                MainAxisSize.min,


            children: [


              Icon(

                paid
                    ? Icons.check_circle_outline
                    : Icons.error_outline,


                size:
                    90,


                color:
                    paid
                        ? Colors.green
                        : Colors.red,
              ),



              const SizedBox(
                height:
                    16,
              ),



              Text(

                paid
                    ? 'پرداخت با موفقیت انجام شد'
                    : 'پرداخت ناموفق بود',


                style:
                    Theme.of(context)
                        .textTheme
                        .titleLarge
                        ?.copyWith(
                          fontWeight:
                              FontWeight.bold,
                        ),
              ),



              const SizedBox(
                height:
                    10,
              ),



              Text(
                'شماره سفارش: ${order.orderNumber}',
              ),



              const SizedBox(
                height:
                    6,
              ),



              Text(
                'مبلغ: ${money(order.total)} تومان',
              ),



              const SizedBox(
                height:
                    26,
              ),



              FilledButton(

                onPressed: () {

                  Navigator.pushNamedAndRemoveUntil(

                    context,

                    AppRoutes.orderDetail,

                    ModalRoute.withName(
                      AppRoutes.home,
                    ),

                    arguments:
                        order.id,
                  );
                },


                child:
                    const Text(
                  'مشاهده سفارش',
                ),
              ),



              TextButton(

                onPressed: () {

                  Navigator.pushNamedAndRemoveUntil(

                    context,

                    AppRoutes.home,

                    (route) => false,
                  );
                },


                child:
                    const Text(
                  'بازگشت به فروشگاه',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}