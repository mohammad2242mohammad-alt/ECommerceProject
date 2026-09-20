import 'package:flutter/material.dart';

class AppError extends StatelessWidget {
  const AppError({
    super.key,
    required this.message,
    this.onRetry,
    this.title,
  });

  final String message;
  final VoidCallback? onRetry;
  final String? title;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 48),
            if (title != null) ...[
              const SizedBox(height: 12),
              Text(
                title!,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ],
            const SizedBox(height: 12),
            Text(message, textAlign: TextAlign.center),
            if (onRetry != null) ...[
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: onRetry,
                child: const Text('تلاش مجدد'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
