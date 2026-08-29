import 'package:flutter/material.dart';
import '../widgets/product_admin_card.dart';
import'add_product_screen.dart';
class ManageProductsScreen extends StatelessWidget {
  const ManageProductsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
//بالای صفحه
      appBar: AppBar(
        title: const Text('Manage Products'),
      ),
//لیست برای محصولات
      body: ListView(
        padding: const EdgeInsets.all(16),

        children: const [

          ProductAdminCard(
            productName: 'Laptop',
            price: '500\$',
          ),

          ProductAdminCard(
            productName: 'Phone',
            price: '300\$',
          ),

        ],
      ),

      // دکمه شناور پایین صفحه برای اضافه کردن محصول
      floatingActionButton: FloatingActionButton(
      onPressed: () {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => const AddProductScreen(),
    ),
  );
},
        child: const Icon(Icons.add),
      ),

    );
  }
}