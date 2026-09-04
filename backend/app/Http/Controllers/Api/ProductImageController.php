<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Product;
use App\Models\ProductImage;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Storage;

class ProductImageController extends Controller
{

    public function index($productId)
    {
        $images = ProductImage::where('product_id', $productId)
            ->orderBy('sort_order')
            ->get()
            ->map(function ($image) {

                return [
                    'id' => $image->id,
                    'url' => Storage::url($image->path),
                    'alt_text' => $image->alt_text,
                    'sort_order' => $image->sort_order,
                    'is_primary' => $image->is_primary,
                ];

            });


        return response()->json([
            'success' => true,
            'message' => 'Success',
            'data' => $images
        ]);
    }



    public function store(Request $request, $productId)
    {

        $request->validate([

            'image' => [
                'required',
                'image',
                'max:2048'
            ],

            'is_primary' => [
                'nullable',
                'boolean'
            ],

            'sort_order' => [
                'nullable',
                'integer',
                'min:0',
            ],

            'alt_text' => [
                'nullable',
                'string',
                'max:255',
            ]

        ]);



        $product = Product::findOrFail($productId);



        $isPrimary = $request->boolean('is_primary');

        if (!$product->images()->exists()) {
            $isPrimary = true;
        }

        // ذخیره فایل
        $path = $request->file('image')
            ->store('products', 'public');



        // اگر عکس اصلی است
        if ($isPrimary) {

            ProductImage::where('product_id', $productId)
                ->update([
                    'is_primary' => false
                ]);

        }



        $image = ProductImage::create([

            'product_id' => $product->id,

            'path' => $path,

            'alt_text' => $request->alt_text,

            'sort_order' => $request->integer('sort_order', 0),

            'is_primary' => $isPrimary

        ]);



        return response()->json([

            'success' => true,

            'message' => 'Image uploaded',

            'data' => [

                'id' => $image->id,

                'url' => Storage::url($image->path),

                'is_primary' => $image->is_primary

            ]

        ]);

    }



    public function destroy($id)
    {

        $image = ProductImage::with('product')->findOrFail($id);

        $wasPrimary = $image->is_primary;


        Storage::disk('public')->delete($image->path);


        $image->delete();

        if ($wasPrimary) {
            $image->product?->images()
                ->orderBy('sort_order')
                ->orderBy('id')
                ->first()?->update(['is_primary' => true]);
        }



        return response()->json([

            'success' => true,

            'message' => 'Image deleted',

            'data' => null,

        ]);

    }

}
