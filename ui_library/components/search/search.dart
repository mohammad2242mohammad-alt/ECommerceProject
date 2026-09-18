import 'package:flutter/material.dart';

/// Reusable search component. The page decides what happens with the query.
class SearchComponent extends StatelessWidget {
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final VoidCallback? onFilterTap;
  final String hintText;
  final bool autofocus;

  const SearchComponent({
    super.key,
    this.controller,
    this.onChanged,
    this.onSubmitted,
    this.onFilterTap,
    this.hintText = 'جستجوی محصول، برند یا دسته‌بندی',
    this.autofocus = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              autofocus: autofocus,
              onChanged: onChanged,
              onSubmitted: onSubmitted,
              textInputAction: TextInputAction.search,
              decoration: InputDecoration(
                hintText: hintText,
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: theme.colorScheme.surfaceContainerHighest,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
              ),
            ),
          ),
          if (onFilterTap != null) ...[
            const SizedBox(width: 8),
            IconButton.filledTonal(
              onPressed: onFilterTap,
              tooltip: 'فیلتر',
              icon: const Icon(Icons.tune),
            ),
          ],
        ],
      ),
    );
  }
}
