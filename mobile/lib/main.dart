// ابزارها و Widgetهای اصلی Flutter Material را وارد می‌کنیم.
import 'package:flutter/material.dart';

// Theme مرکزی پروژه را از مسیر core وارد می‌کنیم.
// تمام تنظیمات ظاهری برنامه در این فایل مدیریت می‌شود.
import 'core/theme/app_theme.dart';

// Route های اصلی برنامه را وارد می‌کنیم.
// مدیریت مسیرهای صفحات در این بخش انجام می‌شود.
import 'core/routes/app_routes.dart';


// نقطه شروع اجرای برنامه Flutter.
void main() {

  // اجرای Widget اصلی برنامه.
  runApp(const EcommerceApp());
}


/// Widget ریشه و اصلی برنامه.
///
/// تمام تنظیمات عمومی پروژه مانند:
/// - Theme
/// - زبان برنامه
/// - جهت نمایش RTL
/// - Routing
///
/// از این قسمت کنترل می‌شوند.
class EcommerceApp extends StatelessWidget {

  // سازنده Widget اصلی برنامه.
  const EcommerceApp({super.key});


  @override
  Widget build(BuildContext context) {

    // MaterialApp هسته اصلی برنامه Flutter است.
    // تنظیمات کلی اپلیکیشن در این Widget قرار می‌گیرد.
    return MaterialApp(

      // نام برنامه.
      title: 'E-Commerce',


      // اتصال Theme مرکزی پروژه.
      // تنظیمات رنگ، فونت و ظاهر برنامه از AppTheme گرفته می‌شود.
      theme: AppTheme.lightTheme,


      // زبان پیش‌فرض برنامه فارسی است.
      locale: const Locale('fa'),


      // حذف نوار Debug در نسخه نهایی.
      debugShowCheckedModeBanner: false,


      // Builder برای اعمال تنظیمات روی تمام صفحات استفاده می‌شود.
      builder: (context, child) {

        // Directionality جهت نمایش رابط کاربری را مشخص می‌کند.
        return Directionality(

          // چون فروشگاه فارسی است، رابط کاربری RTL است.
          textDirection: TextDirection.rtl,


          // صفحه فعلی برنامه.
          child: child ?? const SizedBox.shrink(),
        );
      },


      // اولین صفحه‌ای که بعد از اجرای برنامه نمایش داده می‌شود.
      initialRoute: AppRoutes.home,


      // تمام مسیرهای برنامه از اینجا خوانده می‌شوند.
      routes: AppRoutes.routes,
    );
  }
}