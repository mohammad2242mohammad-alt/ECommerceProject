import 'package:flutter/material.dart';

import '../../../data/models/cart_model.dart';
import '../../../shared/widgets/store_widgets.dart';

class CartItemCard extends StatelessWidget {
  const CartItemCard({
    super.key,
    required this.item,
    required this.onDecrease,
    required this.onIncrease,
    required this.onDelete,
  });

  final CartItemModel item;
  final VoidCallback? onDecrease;
  final VoidCallback? onIncrease;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Row(
          children: [
            NetworkImageBox(
              url: item.product.image,
              width: 82,
              height: 82,
              fit: BoxFit.contain,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.product.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 6),
                  Text('\${money(item.price)} تومان'),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      IconButton(
                        onPressed: onDecrease,
                        icon: const Icon(Icons.remove_circle_outline),
                      ),
                      Text('\${item.quantity}'),
                      IconButton(
                        onPressed: onIncrease,
                        icon: const Icon(Icons.add_circle_outline),
                      ),
                      const Spacer(),
                      IconButton(
                        onPressed: onDelete,
                        icon: const Icon(
                          Icons.delete_outline,
                          color: Colors.red,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CartSummaryCard extends StatelessWidget {
  const CartSummaryCard({
    super.key,
    required this.subtotal,
    required this.onCheckout,
  });

  final num subtotal;
  final VoidCallback onCheckout;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                const Text('جمع اقلام'),
                const Spacer(),
                Text('\${money(subtotal)} تومان'),
              ],
            ),
            const SizedBox(height: 8),
            const Text(
              'مبلغ نهایی و هزینه ارسال در مرحله پرداخت توسط سرور محاسبه می‌شود.',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 14),
            FilledButton.icon(
              onPressed: onCheckout,
              icon: const Icon(Icons.arrow_back),
              label: const Text('ادامه و تسویه حساب'),
            ),
          ],
        ),
      ),
    );
  }
}

class CartLoginRequired extends StatelessWidget {
  const CartLoginRequired({
    super.key,
    required this.onLogin,
  });

  final VoidCallback onLogin;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('سبد خرید'),
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.lock_outline,
              size: 58,
              color: Colors.grey,
            ),
            const SizedBox(height: 12),
            const Text('برای مشاهده سبد خرید ابتدا وارد حساب شوید'),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: onLogin,
              child: const Text('ورود / ثبت‌نام'),
            ),
          ],
        ),
      ),
    );
  }
}
