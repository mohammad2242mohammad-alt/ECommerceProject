<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Banner;
use Illuminate\Support\Facades\Storage;

class BannerController extends Controller
{
    public function index()
    {
        $banners = Banner::query()
            ->where('is_active', true)
            ->where(function ($query) {
                $query
                    ->whereNull('starts_at')
                    ->orWhere('starts_at', '<=', now());
            })
            ->where(function ($query) {
                $query
                    ->whereNull('ends_at')
                    ->orWhere('ends_at', '>=', now());
            })
            ->orderBy('sort_order')
            ->orderByDesc('id')
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

        return response()->json([
            'success' => true,
            'message' => 'Success',
            'data' => $banners,
        ]);
    }
}
