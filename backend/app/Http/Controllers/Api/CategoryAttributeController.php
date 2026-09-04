<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\CategoryAttribute;
use Illuminate\Http\Request;
use Illuminate\Http\JsonResponse;

class CategoryAttributeController extends Controller
{
    public function index($categoryId): JsonResponse
    {
        $attributes = CategoryAttribute::where('category_id', $categoryId)
            ->orderBy('sort_order')
            ->get();


        return response()->json([
            'success' => true,
            'message' => 'Success',
            'data' => $attributes,
        ]);
    }


    public function store(Request $request, $categoryId): JsonResponse
    {
        $validated = $request->validate([

            'name' => 'required|string|max:255',

            'slug' => 'required|string|max:255',

            'type' => 'nullable|string|max:50',

            'is_required' => 'boolean',

            'sort_order' => 'nullable|integer',

        ]);


        $attribute = CategoryAttribute::create([

            'category_id' => $categoryId,

            'name' => $validated['name'],

            'slug' => $validated['slug'],

            'type' => $validated['type'] ?? 'text',

            'is_required' => $validated['is_required'] ?? false,

            'sort_order' => $validated['sort_order'] ?? 0,

        ]);


        return response()->json([

            'success' => true,

            'message' => 'Attribute created',

            'data' => $attribute,

        ], 201);
    }


    public function update(Request $request, $id): JsonResponse
    {
        $attribute = CategoryAttribute::findOrFail($id);


        $validated = $request->validate([

            'name' => 'sometimes|string|max:255',

            'slug' => 'sometimes|string|max:255',

            'type' => 'nullable|string|max:50',

            'is_required' => 'boolean',

            'sort_order' => 'integer',

        ]);


        $attribute->update($validated);


        return response()->json([

            'success' => true,

            'message' => 'Attribute updated',

            'data' => $attribute,

        ]);
    }


    public function destroy($id): JsonResponse
    {
        $attribute = CategoryAttribute::findOrFail($id);

        $attribute->delete();


        return response()->json([

            'success' => true,

            'message' => 'Attribute deleted',

        ]);
    }
}