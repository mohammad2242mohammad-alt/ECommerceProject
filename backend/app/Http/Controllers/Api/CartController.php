<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Cart;
use App\Models\CartItem;
use App\Models\Product;
use App\Models\ProductVariant;
use Illuminate\Http\Request;

class CartController extends Controller
{
    public function index(Request $request)
    {
        $userId = $request->user()->id;

        $cart = Cart::with([
            'items.product',
            'items.variant.values.attribute',
        ])
            ->where('user_id', $userId)
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
        $request->validate([
            'product_id' => 'required|exists:products,id',
            'product_variant_id' => 'nullable|exists:product_variants,id',
            'quantity' => 'required|integer|min:1',
        ]);

        $userId = $request->user()->id;

        $cart = Cart::firstOrCreate([
            'user_id' => $userId,
        ]);

        $item = CartItem::where('cart_id', $cart->id)
            ->where('product_id', $request->product_id)
            ->where('product_variant_id', $request->product_variant_id)
            ->first();

        if ($item) {
            $item->update([
                'quantity' => $item->quantity + $request->quantity,
            ]);
        } else {
            if ($request->product_variant_id) {
                $variant = ProductVariant::findOrFail(
                    $request->product_variant_id
                );

                if ((int) $variant->product_id !== (int) $request->product_id) {
                    return response()->json([
                        'success' => false,
                        'message' => 'Product variant does not belong to the selected product.',
                    ], 422);
                }

                $price = $variant->discount_price ?? $variant->price;
            } else {
                $product = Product::findOrFail(
                    $request->product_id
                );

                $price = $product->discount_price ?? $product->price;
            }

            CartItem::create([
                'cart_id' => $cart->id,
                'product_id' => $request->product_id,
                'product_variant_id' => $request->product_variant_id,
                'quantity' => $request->quantity,
                'price' => $price,
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

    public function update(Request $request, $id)
    {
        $request->validate([
            'quantity' => 'required|integer|min:1',
        ]);

        $userId = $request->user()->id;

        $cart = Cart::where('user_id', $userId)->firstOrFail();

        $item = CartItem::where('cart_id', $cart->id)
            ->where('id', $id)
            ->firstOrFail();

        $item->update([
            'quantity' => $request->quantity,
        ]);

        return response()->json([
            'success' => true,
            'message' => 'Cart updated',
            'data' => $item,
        ]);
    }

    public function destroy(Request $request, $id)
    {
        $userId = $request->user()->id;

        $cart = Cart::where('user_id', $userId)->firstOrFail();

        $item = CartItem::where('cart_id', $cart->id)
            ->where('id', $id)
            ->firstOrFail();

        $item->delete();

        return response()->json([
            'success' => true,
            'message' => 'Item removed',
        ]);
    }
}