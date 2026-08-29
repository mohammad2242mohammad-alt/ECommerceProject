



import 'package:flutter/material.dart';
import 'manage_products_screen.dart';
class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    //اسکلت صفحه
    return Scaffold(
//بالای صفحه
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
      ),
//محتوای صفحه
      body: Padding(
        padding: const EdgeInsets.all(16),

        child: Column(
          children: [

            const Text(
              'Welcome Admin',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),


            const SizedBox(height: 20),

//باکس طراحی شده
//آیتم های لیستیlisttile
            Card(
              child: ListTile(
                leading: const Icon(Icons.shopping_bag),
                title: const Text('Products'),
                subtitle: const Text('Manage Products'),
                onTap: () {
                Navigator.push(
                 context,
                MaterialPageRoute(
                builder: (context) => const ManageProductsScreen(),
    ),
  );
},
                },
              ),
            ),


            Card(
              child: ListTile(
                leading: const Icon(Icons.category),
                title: const Text('Categories'),
                subtitle: const Text('Manage Categories'),
                onTap: () {
                Navigator.push(
                context,
                MaterialPageRoute(
                builder: (context) => const ManageCategoriesScreen(),
    ),
  );
},
              ),
            ),


            Card(
              child: ListTile(
                leading: const Icon(Icons.receipt),
                title: const Text('Orders'),
                subtitle: const Text('Manage Orders'),
                onTap: () {}
                },
              ),
            ),

          ],
        ),
      ),
    );
  }
}