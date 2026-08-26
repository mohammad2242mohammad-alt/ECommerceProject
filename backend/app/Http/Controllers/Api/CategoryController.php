<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Resources\CategoryResource;
use App\Models\Category;
use Illuminate\Http\JsonResponse;

class CategoryController extends Controller
{
    public function index(): JsonResponse
    {
        $categories = Category::query()
            ->where('is_active', true)
            ->whereNull('parent_id')
            ->with([
                'children' => function ($query) {
                    $query->where('is_active', true)
                        ->orderBy('sort_order');
                }
            ])
            ->orderBy('sort_order')
            ->get();

        return response()->json([
            'success' => true,
            'message' => 'Success',
            'data' => CategoryResource::collection($categories),
        ]);
    }

    public function show(int $id): JsonResponse
    {
        $category = Category::query()
            ->where('is_active', true)
            ->with([
                'parent',
                'children' => function ($query) {
                    $query->where('is_active', true)
                        ->orderBy('sort_order');
                }
            ])
            ->findOrFail($id);

        return response()->json([
            'success' => true,
            'message' => 'Success',
            'data' => new CategoryResource($category),
        ]);
    }
}