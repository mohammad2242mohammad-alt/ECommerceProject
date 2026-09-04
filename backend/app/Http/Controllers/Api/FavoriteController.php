<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Favorite;
use Illuminate\Http\Request;

class FavoriteController extends Controller
{
    public function index(Request $request)
    {
        $favorites = Favorite::with([
            'product.category',
            'product.images',
        ])
            ->where(
                'user_id',
                $request->user()->id
            )
            ->latest('created_at')
            ->paginate(20);

        return response()->json([
            'success' => true,
            'message' => 'Success',
            'data' => $favorites,
        ]);
    }

    public function store(Request $request)
    {
        $validated = $request->validate([
            'product_id' => [
                'required',
                'integer',
                'exists:products,id',
            ],
        ]);

        $favorite = Favorite::firstOrCreate([
            'user_id' => $request->user()->id,
            'product_id' => $validated['product_id'],
        ], [
            'created_at' => now(),
        ]);

        return response()->json([
            'success' => true,
            'message' => 'Product added to favorites',
            'data' => $favorite->load('product'),
        ], 201);
    }

    public function destroy(
        Request $request,
        int $productId
    ) {
        $favorite = Favorite::where(
            'user_id',
            $request->user()->id
        )
            ->where(
                'product_id',
                $productId
            )
            ->first();

        if (!$favorite) {
            return response()->json([
                'success' => false,
                'message' => 'Favorite not found',
                'errors' => null,
            ], 404);
        }

        $favorite->delete();

        return response()->json([
            'success' => true,
            'message' => 'Product removed from favorites',
            'data' => null,
        ]);
    }
}