<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Cart;
use App\Models\CartItem;
use App\Models\Product;
use App\Models\ProductVariant;
use Illuminate\Http\Request;
use Illuminate\Validation\ValidationException;

class CartController extends Controller
{
    public function index(Request $request)
    {
        $validated = $request->validate([
            'session_id' => 'required|string|max:100',
        ]);

        $cart = Cart::with([
            'items.product',
            'items.variant.values.attribute',
        ])
            ->where('session_id', $validated['session_id'])
            ->first();

        if (!$cart) {
            return response()->json([
                'success' => true,
                'message' => 'Cart is empty',
                'data' => null,
            ]);
        }

        return response()->json([
            'success' => true,
            'message' => 'Success',
            'data' => $cart,
        ]);
    }

    public function store(Request $request)
    {
        $validated = $request->validate([
            'session_id' => 'required|string|max:100',
            'product_id' => 'required|integer|exists:products,id',
            'product_variant_id' =>
                'nullable|integer|exists:product_variants,id',
            'quantity' => 'required|integer|min:1|max:100',
        ]);

        $product = Product::where(
            'id',
            $validated['product_id']
        )
            ->where('status', 'active')
            ->first();

        if (!$product) {
            throw ValidationException::withMessages([
                'product_id' => [
                    'Product is not available.',
                ],
            ]);
        }

        $variant = null;

        if (!empty($validated['product_variant_id'])) {
            $variant = ProductVariant::where(
                'id',
                $validated['product_variant_id']
            )
                ->where(
                    'product_id',
                    $product->id
                )
                ->where(
                    'is_active',
                    true
                )
                ->first();

            if (!$variant) {
                throw ValidationException::withMessages([
                    'product_variant_id' => [
                        'Selected variant is not available for this product.',
                    ],
                ]);
            }
        }

        $cart = Cart::firstOrCreate([
            'session_id' =>
                $validated['session_id'],
        ]);

        $item = CartItem::where(
            'cart_id',
            $cart->id
        )
            ->where(
                'product_id',
                $product->id
            )
            ->where(
                'product_variant_id',
                $validated['product_variant_id'] ?? null
            )
            ->first();

        $newQuantity =
            ($item?->quantity ?? 0)
            + $validated['quantity'];

        $availableStock = $variant
            ? $variant->stock
            : $product->stock;

        if ($newQuantity > $availableStock) {
            throw ValidationException::withMessages([
                'quantity' => [
                    'Requested quantity exceeds available stock.',
                ],
            ]);
        }

        $price = $this->resolvePrice(
            $product,
            $variant
        );

        if ($item) {
            $item->update([
                'quantity' => $newQuantity,
                'price' => $price,
            ]);
        } else {
            CartItem::create([
                'cart_id' =>
                    $cart->id,

                'product_id' =>
                    $product->id,

                'product_variant_id' =>
                    $validated[
                        'product_variant_id'
                    ] ?? null,

                'quantity' =>
                    $validated['quantity'],

                'price' =>
                    $price,
            ]);
        }

        return response()->json([
            'success' => true,
            'message' => 'Product added to cart',
            'data' => Cart::with([
                'items.product',
                'items.variant.values.attribute',
            ])->find($cart->id),
        ]);
    }

    public function update(
        Request $request,
        int $id
    ) {
        $validated = $request->validate([
            'session_id' => 'required|string|max:100',
            'quantity' => 'required|integer|min:1|max:100',
        ]);

        $cart = Cart::where(
            'session_id',
            $validated['session_id']
        )->firstOrFail();

        $item = CartItem::where(
            'cart_id',
            $cart->id
        )->findOrFail($id);

        $product = Product::where(
            'id',
            $item->product_id
        )
            ->where(
                'status',
                'active'
            )
            ->first();

        if (!$product) {
            throw ValidationException::withMessages([
                'product_id' => [
                    'Product is not available.',
                ],
            ]);
        }

        $variant = null;

        if ($item->product_variant_id) {
            $variant = ProductVariant::where(
                'id',
                $item->product_variant_id
            )
                ->where(
                    'product_id',
                    $product->id
                )
                ->where(
                    'is_active',
                    true
                )
                ->first();

            if (!$variant) {
                throw ValidationException::withMessages([
                    'product_variant_id' => [
                        'Selected variant is not available.',
                    ],
                ]);
            }
        }

        $availableStock = $variant
            ? $variant->stock
            : $product->stock;

        if (
            $validated['quantity']
            > $availableStock
        ) {
            throw ValidationException::withMessages([
                'quantity' => [
                    'Requested quantity exceeds available stock.',
                ],
            ]);
        }

        $price = $this->resolvePrice(
            $product,
            $variant
        );

        $item->update([
            'quantity' =>
                $validated['quantity'],

            'price' =>
                $price,
        ]);

        return response()->json([
            'success' => true,
            'message' => 'Cart updated',
            'data' => $item->fresh(),
        ]);
    }

    public function destroy(
        Request $request,
        int $id
    ) {
        $validated = $request->validate([
            'session_id' => 'required|string|max:100',
        ]);

        $cart = Cart::where(
            'session_id',
            $validated['session_id']
        )->firstOrFail();

        $item = CartItem::where(
            'cart_id',
            $cart->id
        )->findOrFail($id);

        $item->delete();

        return response()->json([
            'success' => true,
            'message' => 'Item removed',
            'data' => null,
        ]);
    }

    private function resolvePrice(
        Product $product,
        ?ProductVariant $variant
    ): float {
        if ($variant) {
            return (float) (
                $variant->discount_price
                ?? $variant->price
                ?? $product->discount_price
                ?? $product->price
            );
        }

        return (float) (
            $product->discount_price
            ?? $product->price
        );
    }
}