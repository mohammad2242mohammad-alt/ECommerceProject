<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\ProductVariant;
use App\Models\Product;
use Illuminate\Http\Request;
use Illuminate\Http\JsonResponse;
use Illuminate\Support\Facades\DB;

class ProductVariantController extends Controller
{
    public function index($productId): JsonResponse
    {
        $product = Product::where('status', 'active')->findOrFail($productId);

        $variants = ProductVariant::with('values.attribute')
            ->where('product_id', $productId)
            ->where('status', 'active')
            ->get();


        return response()->json([
            'success' => true,
            'message' => 'Success',
            'data' => $variants,
        ]);
    }


    public function store(Request $request, $productId): JsonResponse
    {
        Product::where('status', 'active')->findOrFail($productId);

        $validated = $request->validate([

            'sku' => 'nullable|string',

            'price' => 'nullable|numeric',

            'discount_price' => 'nullable|numeric',

            'stock' => 'required|integer',

            'is_active' => 'boolean',

            'status' => 'nullable|in:active,inactive',

        ]);

        $isActive = array_key_exists('status', $validated)
            ? $validated['status'] === 'active'
            : ($validated['is_active'] ?? true);


        $variant = ProductVariant::create([

            'product_id' => $productId,

            'sku' => $validated['sku'] ?? null,

            'price' => $validated['price'] ?? null,

            'discount_price' => $validated['discount_price'] ?? null,

            'stock' => $validated['stock'],

            'is_active' => $isActive,

            'status' => $validated['status']
                ?? ($isActive ? 'active' : 'inactive'),

        ]);


        return response()->json([

            'success' => true,

            'message' => 'Variant created',

            'data' => $variant,

        ], 201);
    }


    public function update(Request $request, $id): JsonResponse
    {
        $variant = ProductVariant::findOrFail($id);


        $validated = $request->validate([

            'sku' => 'nullable|string',

            'price' => 'nullable|numeric',

            'discount_price' => 'nullable|numeric',

            'stock' => 'integer',

            'is_active' => 'boolean',

            'status' => 'nullable|in:active,inactive',

        ]);


        if (array_key_exists('status', $validated)) {
            $validated['is_active'] = $validated['status'] === 'active';
        } elseif (array_key_exists('is_active', $validated)) {
            $validated['status'] = $validated['is_active']
                ? 'active'
                : 'inactive';
        }

        $variant->update($validated);


        return response()->json([

            'success' => true,

            'message' => 'Variant updated',

            'data' => $variant,

        ]);
    }


    public function destroy($id): JsonResponse
    {
        $variant = ProductVariant::findOrFail($id);

        $cartReferenced = DB::table('cart_items')
            ->where('variant_id', $variant->id)
            ->orWhere('product_variant_id', $variant->id)
            ->exists();

        $orderReferenced = DB::table('order_items')
            ->where('variant_id', $variant->id)
            ->orWhere('product_variant_id', $variant->id)
            ->exists();

        if ($cartReferenced || $orderReferenced) {
            return response()->json([
                'success' => false,
                'message' => 'Variant has operational references and cannot be deleted.',
                'errors' => null,
            ], 422);
        }

        $variant->delete();


        return response()->json([

            'success' => true,

            'message' => 'Variant deleted',

            'data' => null,

        ]);
    }
}
