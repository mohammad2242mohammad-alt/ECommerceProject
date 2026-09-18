import 'app_empty.dart';

export 'app_empty.dart';
export 'network_image_box.dart';
export 'section_title.dart';
export 'status_chip.dart';
export 'store_formatters.dart';

/// Backward-compatible alias for the shared empty state.
///
/// New code should use [AppEmpty] directly.
class EmptyState extends AppEmpty {
  const EmptyState({
    super.key,
    required super.message,
    super.icon,
    super.title,
    super.actionLabel,
    super.onAction,
  });
}
