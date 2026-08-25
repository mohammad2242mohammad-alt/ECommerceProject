import 'package:flutter/material.dart';
/// نوار بالای صفحه اصلی فروشگاه.
///
/// این Widget مسئول نمایش بخش بالایی صفحه Home است.
/// در حال حاضر شامل:
/// - عنوان فروشگاه
/// - آیکون سبد خرید
///
/// در مراحل بعدی می‌توانیم قابلیت‌هایی مثل:
/// - ورود / ثبت‌نام
/// - اعلان‌ها
/// - سبد خرید واقعی
/// - پروفایل کاربر
/// را به این بخش اضافه کنیم.
class HomeAppBar extends StatelessWidget {
  const HomeAppBar({super.key});
  @override
  Widget build(BuildContext context) {
    return AppBar(
      // عنوان اصلی فروشگاه
      title: const Text(
        'فروشگاه اینترنتی',
      ),
      // دکمه‌ها و آیکون‌های سمت راست AppBar
      actions: [
        // آیکون سبد خرید
        //
        // فعلاً عملکرد آن خالی است.
        // در مراحل بعدی به صفحه سبد خرید متصل خواهد شد.
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