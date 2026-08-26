<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\VariantValue;
use Illuminate\Http\Request;
use Illuminate\Http\JsonResponse;

class VariantValueController extends Controller
{
    public function index($variantId): JsonResponse
    {
        $values = VariantValue::with('attribute')
            ->where('product_variant_id', $variantId)
            ->get();


        return response()->json([
            'success' => true,
            'message' => 'Success',
            'data' => $values,
        ]);
    }


    public function store(Request $request, $variantId): JsonResponse
    {
        $validated = $request->validate([

            'category_attribute_id' => 'required|exists:category_attributes,id',

            'value' => 'required|string',

        ]);


        $variantValue = VariantValue::create([

            'product_variant_id' => $variantId,

            'category_attribute_id' => $validated['category_attribute_id'],

            'value' => $validated['value'],

        ]);


        return response()->json([

            'success' => true,

            'message' => 'Variant value created',

            'data' => $variantValue,

        ], 201);
    }


    public function update(Request $request, $id): JsonResponse
    {
        $variantValue = VariantValue::findOrFail($id);


        $validated = $request->validate([

            'value' => 'required|string',

        ]);


        $variantValue->update($validated);


        return response()->json([

            'success' => true,

            'message' => 'Variant value updated',

            'data' => $variantValue,

        ]);
    }


    public function destroy($id): JsonResponse
    {
        $variantValue = VariantValue::findOrFail($id);


        $variantValue->delete();


        return response()->json([

            'success' => true,

            'message' => 'Variant value deleted',

        ]);
    }
}
