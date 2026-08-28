<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Order;
use App\Models\Review;
use Illuminate\Http\Request;

class ReviewController extends Controller
{
    public function index(int $productId)
    {
        $reviews = Review::with('user:id,name')
            ->where(
                'product_id',
                $productId
            )
            ->where(
                'status',
                'approved'
            )
            ->latest()
            ->paginate(20);

        return response()->json([
            'success' => true,
            'message' => 'Success',
            'data' => $reviews,
        ]);
    }

    public function store(
        Request $request,
        int $productId
    ) {
        $validated = $request->validate([
            'rating' => [
                'required',
                'integer',
                'between:1,5',
            ],

            'title' => [
                'nullable',
                'string',
                'max:255',
            ],

            'body' => [
                'required',
                'string',
                'max:5000',
            ],
        ]);

        $userId = $request->user()->id;

        $order = Order::where(
            'user_id',
            $userId
        )
            ->where(
                'order_status',
                'delivered'
            )
            ->whereHas(
                'items',
                function ($query) use ($productId) {
                    $query->where(
                        'product_id',
                        $productId
                    );
                }
            )
            ->latest()
            ->first();

        if (!$order) {
            return response()->json([
                'success' => false,
                'message' =>
                    'Only customers with a delivered order can review this product',
                'errors' => null,
            ], 403);
        }

        $alreadyReviewed = Review::where(
            'user_id',
            $userId
        )
            ->where(
                'product_id',
                $productId
            )
            ->exists();

        if ($alreadyReviewed) {
            return response()->json([
                'success' => false,
                'message' =>
                    'You have already reviewed this product',
                'errors' => null,
            ], 422);
        }

        $review = Review::create([
            'user_id' => $userId,
            'product_id' => $productId,
            'order_id' => $order->id,

            'rating' =>
                $validated['rating'],

            'title' =>
                $validated['title'] ?? null,

            'body' =>
                $validated['body'],

            'status' =>
                'pending',
        ]);

        return response()->json([
            'success' => true,
            'message' =>
                'Review submitted and is pending moderation',
            'data' => $review,
        ], 201);
    }
}