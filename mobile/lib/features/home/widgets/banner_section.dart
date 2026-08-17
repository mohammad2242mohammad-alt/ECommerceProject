import 'package:flutter/material.dart';

/// بخش بنرهای تبلیغاتی صفحه اصلی
///
/// در آینده تصاویر این بخش از API دریافت می‌شوند.
class BannerSection extends StatelessWidget {

  const BannerSection({super.key});


  @override
  Widget build(BuildContext context) {

    final banners = [
      'پیشنهاد ویژه امروز',
      'تخفیف محصولات دیجیتال',
      'جدیدترین کالاها',
    ];


    return SizedBox(

      height: 160,

      child: PageView.builder(

        itemCount: banners.length,


        itemBuilder: (context, index) {

          return Container(

            margin: const EdgeInsets.symmetric(
              horizontal: 8,
            ),


            decoration: BoxDecoration(

              borderRadius: BorderRadius.circular(16),

              color: Colors.grey.shade300,

            ),


            child: Center(

              child: Text(

                banners[index],

                style: const TextStyle(

                  fontSize: 24,

                  fontWeight: FontWeight.bold,

                ),

              ),

            ),

          );

        },

      ),

    );

  }

}