import 'package:flutter/material.dart';

import 'layout_engine.dart';

/// Maps stable layout ids from layout configs to reusable section builders.
/// Pages provide the actual widgets; this layer only controls ordering.
class LayoutRegistry {
  final Map<String, WidgetBuilder> _builders;

  LayoutRegistry({required Map<String, WidgetBuilder> builders})
      : _builders = Map.unmodifiable(builders);

  bool contains(String id) => _builders.containsKey(id);

  List<LayoutSection> buildSections(
    BuildContext context,
    List<String> sectionIds, {
    bool skipUnknown = true,
  }) {
    final sections = <LayoutSection>[];

    for (final id in sectionIds) {
      final builder = _builders[id];
      if (builder == null) {
        if (!skipUnknown) {
          throw ArgumentError('Unknown layout section: $id');
        }
        continue;
      }

      sections.add(
        LayoutSection(
          id: id,
          builder: builder,
        ),
      );
    }

    return sections;
  }
}

/// Simple helper for creating a registry without introducing a global state.
LayoutRegistry createLayoutRegistry(Map<String, WidgetBuilder> builders) {
  return LayoutRegistry(builders: builders);
}
