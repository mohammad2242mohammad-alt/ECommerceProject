<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\ProductVariant;
use Illuminate\Http\Request;
use Illuminate\Http\JsonResponse;

class ProductVariantController extends Controller
{
    public function index($productId): JsonResponse
    {
        $variants = ProductVariant::with('values.attribute')
            ->where('product_id', $productId)
            ->get();


        return response()->json([
            'success' => true,
            'message' => 'Success',
            'data' => $variants,
        ]);
    }


    public function store(Request $request, $productId): JsonResponse
    {
        $validated = $request->validate([

            'sku' => 'nullable|string',

            'price' => 'nullable|numeric',

            'discount_price' => 'nullable|numeric',

            'stock' => 'required|integer',

            'is_active' => 'boolean',

        ]);


        $variant = ProductVariant::create([

            'product_id' => $productId,

            'sku' => $validated['sku'] ?? null,

            'price' => $validated['price'] ?? null,

            'discount_price' => $validated['discount_price'] ?? null,

            'stock' => $validated['stock'],

            'is_active' => $validated['is_active'] ?? true,

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

        ]);


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

        $variant->delete();


        return response()->json([

            'success' => true,

            'message' => 'Variant deleted',

        ]);
    }
}