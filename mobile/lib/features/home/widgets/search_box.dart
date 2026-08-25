import 'package:flutter/material.dart';

/// جعبه جستجوی محصولات.
///
/// این Widget برای دریافت عبارت جستجو از کاربر استفاده می‌شود.
///
/// در حال حاضر:
/// - فقط رابط کاربری جستجو را نمایش می‌دهد.
/// - عملیات جستجو هنوز به Backend متصل نشده است.
///
/// در مراحل بعدی:
/// - متن جستجو دریافت می‌شود.
/// - به API محصولات ارسال می‌شود.
/// - نتایج جستجو نمایش داده می‌شوند.
class SearchBox extends StatelessWidget {
  const SearchBox({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      // فاصله جعبه جستجو از اطراف صفحه
      padding: const EdgeInsets.all(16),

      child: TextField(
        // تنظیم ظاهر و اجزای داخل جعبه جستجو
        decoration: InputDecoration(
          // متن راهنما قبل از وارد کردن عبارت جستجو
          hintText: 'جستجوی محصول',

          // آیکون ذره‌بین جستجو
          prefixIcon: const Icon(
            Icons.search,
          ),

          // کادر اطراف جعبه جستجو
          border: OutlineInputBorder(
            // گرد کردن گوشه‌های کادر
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}