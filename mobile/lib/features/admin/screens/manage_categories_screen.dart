import 'package:flutter/material.dart';

class ManageCategoriesScreen extends StatelessWidget {
  const ManageCategoriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      appBar: AppBar(
        title: const Text('Manage Categories'),
      ),

      body: ListView(
        padding: const EdgeInsets.all(16),

        children: const [

          Card(
            child: ListTile(
              leading: Icon(Icons.category),
              title: Text('Laptop'),
              subtitle: Text('Electronics'),
            ),
          ),

          Card(
            child: ListTile(
              leading: Icon(Icons.category),
              title: Text('Phone'),
              subtitle: Text('Electronics'),
            ),
          ),

        ],
      ),
    );
  }
}