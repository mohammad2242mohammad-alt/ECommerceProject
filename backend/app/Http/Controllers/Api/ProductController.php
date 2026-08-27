<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Requests\ProductIndexRequest;
use App\Http\Resources\ProductResource;
use App\Http\Resources\ProductDetailResource;
use App\Models\Category;
use App\Models\Product;
use Illuminate\Http\JsonResponse;

class ProductController extends Controller
{
    public function index(ProductIndexRequest $request): JsonResponse
    {
        $validated = $request->validated();

        $query = Product::query()
            ->with(['category', 'brand'])
            ->where('is_active', 1);

        if (!empty($validated['category_id'])) {
            $categoryId = (int) $validated['category_id'];
            $categoryIds = [$categoryId];
            $pendingIds = [$categoryId];

            while (!empty($pendingIds)) {
                $childIds = Category::query()
                    ->whereIn('parent_id', $pendingIds)
                    ->pluck('id')
                    ->map(fn ($id) => (int) $id)
                    ->all();

                $childIds = array_values(array_diff($childIds, $categoryIds));

                if (empty($childIds)) {
                    break;
                }

                $categoryIds = array_merge($categoryIds, $childIds);
                $pendingIds = $childIds;
            }

            $query->whereIn('category_id', $categoryIds);
        }

        if (!empty($validated['search'])) {
            $search = $validated['search'];
            $query->where(function ($query) use ($search) {
                $query->where('name', 'like', "%{$search}%")
                    ->orWhere('sku', 'like', "%{$search}%")
                    ->orWhere('short_description', 'like', "%{$search}%")
                    ->orWhere('description', 'like', "%{$search}%");
            });
        }

        if (isset($validated['min_price'])) {
            $query->where('price', '>=', $validated['min_price']);
        }

        if (isset($validated['max_price'])) {
            $query->where('price', '<=', $validated['max_price']);
        }

        switch ($validated['sort'] ?? 'newest') {
            case 'oldest':
                $query->orderBy('created_at', 'asc');
                break;
            case 'price_asc':
                $query->orderBy('price', 'asc');
                break;
            case 'price_desc':
                $query->orderBy('price', 'desc');
                break;
            case 'rating_desc':
                $query->orderBy('rating', 'desc');
                break;
            default:
                $query->orderBy('created_at', 'desc');
                break;
        }

        $perPage = $validated['per_page'] ?? 15;
        $products = $query->paginate($perPage);

        return response()->json([
            'success' => true,
            'message' => 'Success',
            'data' => [
                'items' => ProductResource::collection($products->items()),
                'pagination' => [
                    'current_page' => $products->currentPage(),
                    'per_page' => $products->perPage(),
                    'total' => $products->total(),
                    'last_page' => $products->lastPage(),
                    'from' => $products->firstItem(),
                    'to' => $products->lastItem(),
                ],
            ],
        ]);
    }

    public function show($id): JsonResponse
    {
        $product = Product::with([
            'category',
            'brand',
            'images',
            'attributeValues.attribute',
            'variants.values.attribute'
        ])
        ->where('is_active', 1)
        ->findOrFail($id);

        return response()->json([
            'success' => true,
            'message' => 'Success',
            'data' => new ProductDetailResource($product),
        ]);
    }
}
