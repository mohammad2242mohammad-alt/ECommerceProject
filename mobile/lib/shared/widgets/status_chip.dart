import 'package:flutter/material.dart';

class StatusChip extends StatelessWidget {
  const StatusChip({
    super.key,
    required this.label,
    this.color,
  });

  final String label;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Text(label),
      backgroundColor: (color ?? Theme.of(context).colorScheme.primary)
          .withOpacity(.12),
      side: BorderSide.none,
      labelStyle: TextStyle(
        color: color ?? Theme.of(context).colorScheme.primary,
        fontSize: 12,
      ),
    );
  }
}
