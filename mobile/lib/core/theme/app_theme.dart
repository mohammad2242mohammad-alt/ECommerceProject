import 'package:flutter/material.dart';

/// Theme اصلی برنامه فروشگاه.
///
/// تمام تنظیمات ظاهری عمومی برنامه مثل رنگ‌ها، فونت‌ها،
/// شکل دکمه‌ها و سایر اجزای Material در این کلاس متمرکز می‌شوند.
/// این کار باعث می‌شود ظاهر برنامه از یک نقطه قابل مدیریت باشد.
class AppTheme {
  // سازنده خصوصی؛ این کلاس فقط برای نگهداری تنظیمات Theme استفاده می‌شود.
  AppTheme._();

  /// Theme اصلی برنامه در حالت روشن.
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,

    // رنگ پایه برنامه.
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFFEF394E),
      brightness: Brightness.light,
    ),

    // رنگ پس‌زمینه عمومی صفحات.
    scaffoldBackgroundColor: Colors.white,

    // تنظیمات عمومی AppBar.
    appBarTheme: const AppBarTheme(
      centerTitle: true,
      elevation: 0,
      scrolledUnderElevation: 0,
    ),
  );
}