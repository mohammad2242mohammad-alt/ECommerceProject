import 'package:flutter/material.dart';

class AddProductScreen extends StatelessWidget {
  const AddProductScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      appBar: AppBar(
        title: const Text('Add Product'),
      ),
//نچسبیدن محتوا به لبه صفحهPadding
      body: Padding(
        padding: const EdgeInsets.all(16),

        child: Column(
          children: [
//گرفتن ورودی(قیمت ونام محصول..)
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Product Name',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 16),


            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Price',
                border: OutlineInputBorder(),
              ),
            ),


            const SizedBox(height: 16),

//maxLines(تعداد توضیح خط)
            TextFormField(
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(),
              ),
            ),


            const SizedBox(height: 24),


            ElevatedButton(
              onPressed: () {},
              child: const Text('Save Product'),
            ),

          ],
        ),
      ),
    );
  }
}