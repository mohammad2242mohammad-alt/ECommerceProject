<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Cart;
use App\Models\Product;
use App\Models\ProductVariant;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Validation\ValidationException;

class CartController extends Controller
{
    public function index(Request $request): JsonResponse
    {
        $cart = $this->ownedCart($request)->with([
            'items.product',
            'items.variant.values.attribute',
        ])->first();

        return response()->json([
            'success' => true,
            'message' => $cart ? 'Success' : 'Cart is empty',
            'data' => $cart,
        ]);
    }

    public function store(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'product_id' => ['required', 'integer', 'exists:products,id'],
            'variant_id' => ['nullable', 'integer', 'exists:product_variants,id'],
            // Kept temporarily for clients built against the earlier branch.
            'product_variant_id' => ['nullable', 'integer', 'exists:product_variants,id'],
            'quantity' => ['required', 'integer', 'min:1', 'max:100'],
        ]);

        $variantId = $this->resolveVariantId($validated);
        $product = Product::query()
            ->whereKey($validated['product_id'])
            ->where('status', 'active')
            ->first();

        if (!$product) {
            throw ValidationException::withMessages([
                'product_id' => ['Product is not available.'],
            ]);
        }

        $variant = $this->findAvailableVariant($product, $variantId);
        $cart = Cart::firstOrCreate(['user_id' => $request->user()->id]);

        $item = $cart->items()
            ->where('product_id', $product->id)
            ->where('variant_id', $variantId)
            ->first();

        $newQuantity = ($item?->quantity ?? 0) + $validated['quantity'];
        $this->ensureStock($product, $variant, $newQuantity);

        $price = $this->resolvePrice($product, $variant);

        if ($item) {
            $item->update([
                'quantity' => $newQuantity,
                'price' => $price,
                'variant_id' => $variantId,
                'product_variant_id' => $variantId,
            ]);
        } else {
            $cart->items()->create([
                'product_id' => $product->id,
                'variant_id' => $variantId,
                'product_variant_id' => $variantId,
                'quantity' => $validated['quantity'],
                'price' => $price,
            ]);
        }

        return $this->cartResponse($cart, 'Product added to cart');
    }

    public function update(Request $request, int $id): JsonResponse
    {
        $validated = $request->validate([
            'quantity' => ['required', 'integer', 'min:1', 'max:100'],
        ]);

        $cart = $this->ownedCart($request)->firstOrFail();
        $item = $cart->items()->findOrFail($id);
        $product = Product::query()
            ->whereKey($item->product_id)
            ->where('status', 'active')
            ->first();

        if (!$product) {
            throw ValidationException::withMessages([
                'product_id' => ['Product is not available.'],
            ]);
        }

        $variantId = $item->variant_id ?? $item->product_variant_id;
        $variant = $this->findAvailableVariant($product, $variantId);
        $this->ensureStock($product, $variant, $validated['quantity']);

        $item->update([
            'quantity' => $validated['quantity'],
            'price' => $this->resolvePrice($product, $variant),
            'variant_id' => $variantId,
            'product_variant_id' => $variantId,
        ]);

        return response()->json([
            'success' => true,
            'message' => 'Cart updated',
            'data' => $item->fresh()->load('product', 'variant.values.attribute'),
        ]);
    }

    public function destroy(Request $request, int $id): JsonResponse
    {
        $cart = $this->ownedCart($request)->firstOrFail();
        $cart->items()->findOrFail($id)->delete();

        return response()->json([
            'success' => true,
            'message' => 'Item removed',
            'data' => null,
        ]);
    }

    public function clear(Request $request): JsonResponse
    {
        $cart = $this->ownedCart($request)->first();
        $cart?->items()->delete();

        return response()->json([
            'success' => true,
            'message' => 'Cart cleared',
            'data' => null,
        ]);
    }

    private function ownedCart(Request $request)
    {
        return Cart::query()->where('user_id', $request->user()->id);
    }

    private function cartResponse(Cart $cart, string $message): JsonResponse
    {
        return response()->json([
            'success' => true,
            'message' => $message,
            'data' => $cart->fresh()->load([
                'items.product',
                'items.variant.values.attribute',
            ]),
        ]);
    }

    private function resolveVariantId(array $validated): ?int
    {
        $variantId = $validated['variant_id'] ?? null;
        $legacyVariantId = $validated['product_variant_id'] ?? null;

        if ($variantId !== null && $legacyVariantId !== null && $variantId !== $legacyVariantId) {
            throw ValidationException::withMessages([
                'variant_id' => ['variant_id and product_variant_id must match.'],
            ]);
        }

        return $variantId ?? $legacyVariantId;
    }

    private function findAvailableVariant(Product $product, ?int $variantId): ?ProductVariant
    {
        if ($variantId === null) {
            return null;
        }

        $variant = ProductVariant::query()
            ->whereKey($variantId)
            ->where('product_id', $product->id)
            ->where('status', 'active')
            ->first();

        if (!$variant) {
            throw ValidationException::withMessages([
                'variant_id' => ['Selected variant is not available for this product.'],
            ]);
        }

        return $variant;
    }

    private function ensureStock(Product $product, ?ProductVariant $variant, int $quantity): void
    {
        $availableStock = $variant?->stock ?? $product->stock;

        if ($quantity > $availableStock) {
            throw ValidationException::withMessages([
                'quantity' => ['Requested quantity exceeds available stock.'],
            ]);
        }
    }

    private function resolvePrice(Product $product, ?ProductVariant $variant): float
    {
        return (float) (
            $variant?->discount_price
            ?? $variant?->price
            ?? $product->discount_price
            ?? $product->price
        );
    }
}
