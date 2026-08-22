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

            'alt_text' => [
                'nullable',
                'string'
            ]

        ]);



        $product = Product::findOrFail($productId);



        // ذخیره فایل
        $path = $request->file('image')
            ->store('products', 'public');



        // اگر عکس اصلی است
        if ($request->boolean('is_primary')) {

            ProductImage::where('product_id', $productId)
                ->update([
                    'is_primary' => false
                ]);

        }



        $image = ProductImage::create([

            'product_id' => $product->id,

            'path' => $path,

            'alt_text' => $request->alt_text,

            'sort_order' => 0,

            'is_primary' => $request->boolean('is_primary')

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

        $image = ProductImage::findOrFail($id);


        Storage::disk('public')->delete($image->path);


        $image->delete();



        return response()->json([

            'success' => true,

            'message' => 'Image deleted'

        ]);

    }

}