<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\Review;
use Illuminate\Http\Request;
use Illuminate\Validation\Rule;

class AdminReviewController extends Controller
{
    public function index(Request $request)
    {
        $query = Review::with([
            'user',
            'product'
        ])
        ->latest();

        if ($request->filled('status')) {
            $query->where(
                'status',
                $request->status
            );
        }

        $reviews = $query
            ->paginate(20)
            ->withQueryString();

        return view(
            'admin.reviews.index',
            compact('reviews')
        );
    }


    public function updateStatus(
        Request $request,
        Review $review
    )
    {
        $validated = $request->validate([
            'status' => [
                'required',
                Rule::in([
                    'pending',
                    'approved',
                    'rejected'
                ])
            ]
        ]);


        $review->update([
            'status' =>
                $validated['status']
        ]);


        return back()->with(
            'success',
            'وضعیت نظر تغییر کرد.'
        );
    }


    public function destroy(
        Review $review
    )
    {
        $review->delete();

        return back()->with(
            'success',
            'نظر حذف شد.'
        );
    }
}