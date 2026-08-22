<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\ProductAttributeValue;
use Illuminate\Http\Request;
use Illuminate\Http\JsonResponse;

class ProductAttributeValueController extends Controller
{
    public function index($productId): JsonResponse
    {
        $values = ProductAttributeValue::with('attribute')
            ->where('product_id', $productId)
            ->get();


        return response()->json([
            'success' => true,
            'message' => 'Success',
            'data' => $values,
        ]);
    }


    public function store(Request $request, $productId): JsonResponse
    {
        $validated = $request->validate([

            'category_attribute_id' => 'required|exists:category_attributes,id',

            'value' => 'required|string',

        ]);


        $attributeValue = ProductAttributeValue::create([

            'product_id' => $productId,

            'category_attribute_id' => $validated['category_attribute_id'],

            'value' => $validated['value'],

        ]);


        return response()->json([

            'success' => true,

            'message' => 'Product attribute value created',

            'data' => $attributeValue,

        ], 201);
    }


    public function update(Request $request, $id): JsonResponse
    {
        $attributeValue = ProductAttributeValue::findOrFail($id);


        $validated = $request->validate([

            'value' => 'required|string',

        ]);


        $attributeValue->update($validated);


        return response()->json([

            'success' => true,

            'message' => 'Product attribute value updated',

            'data' => $attributeValue,

        ]);
    }


    public function destroy($id): JsonResponse
    {
        $attributeValue = ProductAttributeValue::findOrFail($id);


        $attributeValue->delete();


        return response()->json([

            'success' => true,

            'message' => 'Product attribute value deleted',

        ]);
    }
}