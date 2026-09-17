import 'package:flutter/material.dart';

class LayoutEngine extends StatelessWidget {
  final List<Widget> sections;
  const LayoutEngine({super.key, required this.sections});
  @override
  Widget build(BuildContext context) => ListView(children: sections);
}
