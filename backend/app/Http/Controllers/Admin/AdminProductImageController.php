<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\Product;
use App\Models\ProductImage;
use Illuminate\Http\RedirectResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Storage;

class AdminProductImageController extends Controller
{
    public function store(
        Request $request,
        Product $product
    ): RedirectResponse {
        $validated = $request->validate([
            'image' => [
                'required',
                'image',
                'mimes:jpg,jpeg,png,webp',
                'max:4096',
            ],

            'alt_text' => [
                'nullable',
                'string',
                'max:255',
            ],

            'sort_order' => [
                'required',
                'integer',
                'min:0',
            ],
        ]);

        $isPrimary = $request->boolean('is_primary');

        if (!$product->images()->exists()) {
            $isPrimary = true;
        }

        if ($isPrimary) {
            $product->images()->update([
                'is_primary' => false,
            ]);
        }

        $path = $request
            ->file('image')
            ->store(
                'products/'.$product->id,
                'public'
            );

        $product->images()->create([
            'path' => $path,
            'alt_text' =>
                $validated['alt_text'] ?? null,
            'sort_order' =>
                $validated['sort_order'],
            'is_primary' =>
                $isPrimary,
        ]);

        return back()->with(
            'success',
            'تصویر محصول با موفقیت اضافه شد.'
        );
    }

    public function makePrimary(
        Product $product,
        ProductImage $image
    ): RedirectResponse {
        abort_unless(
            $image->product_id === $product->id,
            404
        );

        $product->images()->update([
            'is_primary' => false,
        ]);

        $image->update([
            'is_primary' => true,
        ]);

        return back()->with(
            'success',
            'تصویر اصلی محصول تغییر کرد.'
        );
    }

    public function destroy(
        Product $product,
        ProductImage $image
    ): RedirectResponse {
        abort_unless(
            $image->product_id === $product->id,
            404
        );

        $wasPrimary = $image->is_primary;

        if ($image->path) {
            Storage::disk('public')
                ->delete($image->path);
        }

        $image->delete();

        if ($wasPrimary) {
            $nextImage = $product
                ->images()
                ->orderBy('sort_order')
                ->orderBy('id')
                ->first();

            $nextImage?->update([
                'is_primary' => true,
            ]);
        }

        return back()->with(
            'success',
            'تصویر محصول حذف شد.'
        );
    }
}