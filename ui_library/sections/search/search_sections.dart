import 'package:flutter/material.dart';

class GenericSection extends StatelessWidget {
  final String name;
  const GenericSection({super.key, required this.name});
  @override
  Widget build(BuildContext context) => Padding(padding: const EdgeInsets.all(16), child: Text(name));
}
