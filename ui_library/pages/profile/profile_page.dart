import 'package:flutter/material.dart';

import '../../layouts/layout_engine.dart';

/// Configurable Profile page. Account state and navigation stay outside.
class ProfilePage extends StatelessWidget {
  final List<LayoutSection> sections;
  final EdgeInsetsGeometry padding;

  const ProfilePage({
    super.key,
    required this.sections,
    this.padding = EdgeInsets.zero,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ConfigurableLayout(
        sections: sections,
        padding: padding,
      ),
    );
  }
}
