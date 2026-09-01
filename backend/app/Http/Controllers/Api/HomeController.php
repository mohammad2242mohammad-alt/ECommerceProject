<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Banner;
use App\Models\Category;
use App\Models\Product;

class HomeController extends Controller
{
    public function index()
    {
        $banners = Banner::where(
            'is_active',
            true
        )
            ->orderBy(
                'sort_order'
            )
            ->get();


        $categories = Category::where(
            'is_active',
            true
        )
            ->orderBy(
                'sort_order'
            )
            ->take(10)
            ->get();


        $products = Product::where(
            'status',
            'active'
        )
            ->latest()
            ->take(10)
            ->get();


        return response()->json([
            'success' => true,
            'message' => 'Success',
            'data' => [
                'banners' => $banners,
                'categories' => $categories,
                'products' => $products,
            ],
        ]);
    }
}