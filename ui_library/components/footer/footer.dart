import 'package:flutter/material.dart';

class FooterLink {
  final String label;
  final VoidCallback? onTap;

  const FooterLink({required this.label, this.onTap});
}

/// Reusable application footer. Navigation and external actions are supplied
/// by the parent page.
class FooterComponent extends StatelessWidget {
  final String? brandTitle;
  final String? description;
  final List<FooterLink> links;
  final String? copyrightText;
  final List<Widget> trailingActions;

  const FooterComponent({
    super.key,
    this.brandTitle,
    this.description,
    this.links = const [],
    this.copyrightText,
    this.trailingActions = const [],
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Container(
        width: double.infinity,
        color: theme.colorScheme.surfaceContainerHighest,
        padding: const EdgeInsets.fromLTRB(20, 28, 20, 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (brandTitle != null) ...[
              Text(
                brandTitle!,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 8),
            ],
            if (description != null) ...[
              Text(
                description!,
                style: theme.textTheme.bodyMedium?.copyWith(height: 1.7),
              ),
              const SizedBox(height: 16),
            ],
            if (links.isNotEmpty) ...[
              Wrap(
                spacing: 8,
                runSpacing: 6,
                children: [
                  for (final link in links)
                    TextButton(
                      onPressed: link.onTap,
                      child: Text(link.label),
                    ),
                ],
              ),
              const SizedBox(height: 10),
            ],
            if (trailingActions.isNotEmpty) ...[
              Wrap(spacing: 8, runSpacing: 8, children: trailingActions),
              const SizedBox(height: 12),
            ],
            const Divider(height: 1),
            if (copyrightText != null) ...[
              const SizedBox(height: 12),
              Text(
                copyrightText!,
                style: theme.textTheme.bodySmall,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
