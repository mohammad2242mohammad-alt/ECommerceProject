import 'package:flutter/material.dart';

import '../../../core/routes/app_routes.dart';
import '../../../data/models/order_model.dart';
import '../../../shared/widgets/store_widgets.dart';
import '../widgets/payment_result_ui_components.dart';


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


              PaymentResultCard(order: order, paid: paid),



              const SizedBox(
                height:
                    26,
              ),



              PaymentResultActions(onViewOrder: () {
                  Navigator.pushNamedAndRemoveUntil(context, AppRoutes.orderDetail, ModalRoute.withName(AppRoutes.home), arguments: order.id);
                }, onBackToStore: () {
                  Navigator.pushNamedAndRemoveUntil(context, AppRoutes.home, (route) => false);
                }),
            ],
          ),
        ),
      ),
    );
  }
}