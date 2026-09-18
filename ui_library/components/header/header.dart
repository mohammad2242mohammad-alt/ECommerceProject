import 'package:flutter/material.dart';

/// Reusable e-commerce header. Visual choices stay configurable so the same
/// component can be placed in different page layouts without rewriting it.
class HeaderComponent extends StatelessWidget {
  final String title;
  final String? subtitle;
  final VoidCallback? onSearch;
  final VoidCallback? onCart;
  final VoidCallback? onProfile;
  final bool showBack;
  final VoidCallback? onBack;
  final Widget? leading;
  final Widget? trailing;

  const HeaderComponent({
    super.key,
    this.title = 'فروشگاه',
    this.subtitle,
    this.onSearch,
    this.onCart,
    this.onProfile,
    this.showBack = false,
    this.onBack,
    this.leading,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: theme.colorScheme.surface,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
          child: Row(
            children: [
              if (showBack)
                IconButton(
                  tooltip: 'بازگشت',
                  onPressed: onBack,
                  icon: const Icon(Icons.arrow_back),
                )
              else if (leading != null)
                leading!,
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        subtitle!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                  ],
                ),
              ),
              if (onSearch != null)
                IconButton(
                  tooltip: 'جستجو',
                  onPressed: onSearch,
                  icon: const Icon(Icons.search),
                ),
              if (onCart != null)
                IconButton(
                  tooltip: 'سبد خرید',
                  onPressed: onCart,
                  icon: const Icon(Icons.shopping_cart_outlined),
                ),
              if (onProfile != null)
                IconButton(
                  tooltip: 'حساب کاربری',
                  onPressed: onProfile,
                  icon: const Icon(Icons.person_outline),
                ),
              if (trailing != null) trailing!,
            ],
          ),
        ),
      ),
    );
  }
}
