<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Requests\ProductIndexRequest;
use App\Http\Resources\ProductDetailResource;
use App\Http\Resources\ProductResource;
use App\Models\Product;
use Illuminate\Http\JsonResponse;

class ProductController extends Controller
{
    public function index(ProductIndexRequest $request): JsonResponse
    {
        $validated = $request->validated();

        $query = Product::query()
            ->with([
                'category',
                'images' => fn ($query) => $query
                    ->orderByDesc('is_primary')
                    ->orderBy('sort_order')
                    ->orderBy('id'),
            ])
            ->where('status', 'active');

        if (!empty($validated['category_id'])) {
            $query->where(
                'category_id',
                $validated['category_id']
            );
        }

        if (!empty($validated['search'])) {
            $search = $validated['search'];

            $query->where(function ($query) use ($search) {
                $query
                    ->where(
                        'name',
                        'like',
                        "%{$search}%"
                    )
                    ->orWhere(
                        'sku',
                        'like',
                        "%{$search}%"
                    )
                    ->orWhere(
                        'short_description',
                        'like',
                        "%{$search}%"
                    )
                    ->orWhere(
                        'description',
                        'like',
                        "%{$search}%"
                    );
            });
        }

        if (isset($validated['min_price'])) {
            $query->where(
                'price',
                '>=',
                $validated['min_price']
            );
        }

        if (isset($validated['max_price'])) {
            $query->where(
                'price',
                '<=',
                $validated['max_price']
            );
        }

        switch ($validated['sort'] ?? 'newest') {
            case 'oldest':
                $query->orderBy(
                    'created_at',
                    'asc'
                );
                break;

            case 'price_asc':
                $query->orderBy(
                    'price',
                    'asc'
                );
                break;

            case 'price_desc':
                $query->orderBy(
                    'price',
                    'desc'
                );
                break;

            case 'rating_desc':
                $query->orderBy(
                    'rating_average',
                    'desc'
                );
                break;

            default:
                $query->orderBy(
                    'created_at',
                    'desc'
                );
                break;
        }

        $perPage = $validated['per_page'] ?? 15;

        $products = $query->paginate($perPage);

        return response()->json([
            'success' => true,
            'message' => 'Success',
            'data' => [
                'items' => ProductResource::collection(
                    $products->items()
                ),

                'pagination' => [
                    'current_page' =>
                        $products->currentPage(),

                    'per_page' =>
                        $products->perPage(),

                    'total' =>
                        $products->total(),

                    'last_page' =>
                        $products->lastPage(),

                    'from' =>
                        $products->firstItem(),

                    'to' =>
                        $products->lastItem(),
                ],
            ],
        ]);
    }

    public function show(int $id): JsonResponse
    {
        $product = Product::with([
            'category',
            'images',
            'attributeValues.attribute',
            'variants' => fn ($query) => $query
                ->where('status', 'active')
                ->with('values.attribute'),
        ])
            ->where('status', 'active')
            ->findOrFail($id);

        return response()->json([
            'success' => true,
            'message' => 'Success',
            'data' => new ProductDetailResource(
                $product
            ),
        ]);
    }
}
