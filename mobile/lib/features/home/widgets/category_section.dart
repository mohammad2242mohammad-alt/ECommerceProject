import 'package:flutter/material.dart';
/// آیتم تکی دسته‌بندی
///
/// هر دسته شامل:
/// - آیکن
/// - عنوان
///
/// بعداً تصویر واقعی از API می‌گیرد.
class CategoryItem extends StatelessWidget {
  final String title;
  final IconData icon;
  const CategoryItem({
    super.key,
    required this.title,
    required this.icon,
  });
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 90,
      child: Column(
        children: [
          CircleAvatar(
            radius: 35,
            backgroundColor:
                Theme.of(context)
                  .colorScheme
                  .primary
                  .withValues(alpha: 0.1),
            child: Icon(
              icon,
              size: 35,
              color: Theme.of(context)
               .colorScheme
               .primary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}