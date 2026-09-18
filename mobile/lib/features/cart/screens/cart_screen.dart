import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/routes/app_routes.dart';
import '../../../providers/store_providers.dart';
import '../../../shared/widgets/store_widgets.dart';
import '../widgets/cart_ui_components.dart';

class CartScreen extends ConsumerWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (ref.watch(authUserProvider) == null) {
      return CartLoginRequired(
        onLogin: () {
          Navigator.pushNamed(
            context,
            AppRoutes.auth,
          );
        },
      );
    }

    final cart = ref.watch(cartProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('سبد خرید'),
      ),
      body: cart.when(
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (error, _) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(error.toString()),
              FilledButton(
                onPressed: () => ref.invalidate(cartProvider),
                child: const Text('تلاش مجدد'),
              ),
            ],
          ),
        ),
        data: (value) {
          if (value == null || value.items.isEmpty) {
            return const EmptyState(
              message: 'سبد خرید شما خالی است',
              icon: Icons.shopping_cart_outlined,
            );
          }

          return ListView(
            padding: const EdgeInsets.all(14),
            children: [
              ...value.items.map(
                (item) => CartItemCard(
                  item: item,
                  onDecrease: item.quantity > 1
                      ? () async {
                          await _update(
                            ref,
                            item.id,
                            item.quantity - 1,
                          );
                        }
                      : null,
                  onIncrease: item.quantity < 100
                      ? () async {
                          await _update(
                            ref,
                            item.id,
                            item.quantity + 1,
                          );
                        }
                      : null,
                  onDelete: () async {
                    await ref
                        .read(storeRepositoryProvider)
                        .deleteCartItem(item.id);
                    ref.invalidate(cartProvider);
                  },
                ),
              ),
              const SizedBox(height: 10),
              CartSummaryCard(
                subtotal: value.estimatedSubtotal,
                onCheckout: () {
                  Navigator.pushNamed(
                    context,
                    AppRoutes.checkout,
                  );
                },
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _update(
    WidgetRef ref,
    int id,
    int quantity,
  ) async {
    try {
      await ref
          .read(storeRepositoryProvider)
          .updateCartItem(
            id,
            quantity,
          );
      ref.invalidate(cartProvider);
    } catch (_) {
      // server error will appear after refresh
    }
  }
}
