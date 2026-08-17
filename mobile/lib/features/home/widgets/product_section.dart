import 'package:flutter/material.dart';
import '../../../data/models/product_model.dart';
import '../../../data/services/product_service.dart';
import '../../products/widgets/product_card.dart';
/// بخش نمایش محصولات ویژه صفحه اصلی
///
/// فعلاً اطلاعات از ProductService آزمایشی دریافت می‌شود.
/// در آینده همین بخش از Laravel API اطلاعات می‌گیرد.
class ProductSection extends StatelessWidget {
  const ProductSection({super.key});
  @override
  Widget build(BuildContext context) {
    final ProductService service = ProductService();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'محصولات ویژه',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        FutureBuilder<List<ProductModel>>(
          future: service.getProducts(),
          builder: (context, snapshot) {
            // هنگام دریافت اطلاعات
            if (!snapshot.hasData) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
            final products = snapshot.data!;
            return GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: products.length,
              gridDelegate:
              const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.65,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemBuilder: (context, index) {
                final ProductModel product = products[index];
                return ProductCard(
                title: product.name,
                price: '${product.price} تومان',
                image: product.image,
                rating: 4.5,
               );
              },
            );
          },
        ),
      ],

    );
  }
}