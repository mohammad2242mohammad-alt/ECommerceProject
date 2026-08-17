import 'package:flutter/material.dart';

/// نوار بالای صفحه اصلی فروشگاه.
class HomeAppBar extends StatelessWidget {

  const HomeAppBar({super.key});


  @override
  Widget build(BuildContext context) {

    return AppBar(

      // عنوان فروشگاه
      title: const Text(
        'فروشگاه اینترنتی',
      ),


      // آیکون‌های سمت راست AppBar
      actions: [

        // آیکون سبد خرید
        IconButton(
          onPressed: () {},
          icon: const Icon(
            Icons.shopping_cart_outlined,
          ),
        ),

      ],

    );

  }

}