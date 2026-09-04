<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Resources\CategoryResource;
use App\Http\Resources\ProductResource;
use App\Models\Banner;
use App\Models\Category;
use App\Models\Product;
use Illuminate\Support\Facades\Storage;

class HomeController extends Controller
{
    public function index()
    {
        $banners = Banner::query()
            ->where('is_active', true)
            ->where(function ($query) {
                $query->whereNull('starts_at')
                    ->orWhere('starts_at', '<=', now());
            })
            ->where(function ($query) {
                $query->whereNull('ends_at')
                    ->orWhere('ends_at', '>=', now());
            })
            ->orderBy('sort_order')
            ->orderByDesc('id')
            ->take(10)
            ->get()
            ->map(function (Banner $banner) {
                $data = $banner->toArray();

                if (
                    $banner->image &&
                    !filter_var($banner->image, FILTER_VALIDATE_URL)
                ) {
                    $data['image'] = Storage::url($banner->image);
                }

                return $data;
            });


        $categories = Category::query()
            ->where('is_active', true)
            ->whereNull('parent_id')
            ->with(['children' => function ($query) {
                $query->where('is_active', true)->orderBy('sort_order');
            }])
            ->orderBy('sort_order')
            ->take(10)
            ->get();


        $products = Product::query()
            ->where('status', 'active')
            ->with(['category', 'images' => function ($query) {
                $query->orderByDesc('is_primary')->orderBy('sort_order');
            }])
            ->latest()
            ->take(10)
            ->get();


        return response()->json([
            'success' => true,
            'message' => 'Success',
            'data' => [
                'banners' => $banners,
                'categories' => CategoryResource::collection($categories),
                'products' => ProductResource::collection($products),
            ],
        ]);
    }
}
