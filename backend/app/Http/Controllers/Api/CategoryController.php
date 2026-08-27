<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Resources\CategoryResource;
use App\Models\Category;
use Illuminate\Http\JsonResponse;

class CategoryController extends Controller
{
    /**
     * Get all active root categories with their active children.
     *
     * Root categories are categories without a parent.
     */
    public function index(): JsonResponse
    {
        $categories = Category::query()
            ->whereNull('parent_id')
            ->where('is_active', 1)
            ->with([
                'children' => function ($query) {
                    $query
                        ->where('is_active', 1)
                        ->orderBy('sort_order');
                },
            ])
            ->orderBy('sort_order')
            ->get();

        return response()->json([
            'success' => true,
            'message' => 'Success',
            'data' => CategoryResource::collection($categories),
        ]);
    }

    /**
     * Get one category with its children.
     */
    public function show(int $id): JsonResponse
    {
        $category = Category::query()
            ->where('is_active', 1)
            ->with([
                'children' => function ($query) {
                    $query
                        ->where('is_active', 1)
                        ->orderBy('sort_order');
                },
            ])
            ->findOrFail($id);

        return response()->json([
            'success' => true,
            'message' => 'Success',
            'data' => new CategoryResource($category),
        ]);
    }
}