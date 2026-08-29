import 'package:flutter/material.dart';

class ProductAdminCard extends StatelessWidget {
  //widgetاین مقدار بعد از ساخت  تغییر نمیکند
  final String productName;
  final String price;

  const ProductAdminCard({
    super.key,
    required this.productName,
    required this.price,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: const Icon(Icons.shopping_bag),

        title: Text(productName),

        subtitle: Text(
          price,
        ),

        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [

            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () {},
            ),

            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () {},
            ),

          ],
        ),
      ),
    );
  }
}