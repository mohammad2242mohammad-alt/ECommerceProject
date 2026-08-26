<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Cart;
use App\Models\CartItem;
use App\Models\Product;
use App\Models\ProductVariant;
use Illuminate\Http\Request;

class CartController extends Controller
{


    public function index(Request $request)
    {

        $cart = Cart::with([

            'items.product',

            'items.variant.values.attribute'

        ])

        ->where('session_id', $request->session_id)

        ->first();



        if (!$cart) {

            return response()->json([

                'success' => true,

                'message' => 'Cart is empty',

                'data' => null

            ]);

        }



        return response()->json([

            'success' => true,

            'message' => 'Success',

            'data' => $cart

        ]);

    }





    public function store(Request $request)
    {

        $request->validate([

            'session_id' => 'required',

            'product_id' => 'required|exists:products,id',

            'product_variant_id' => 'nullable|exists:product_variants,id',

            'quantity' => 'required|integer|min:1'

        ]);




        $cart = Cart::firstOrCreate([

            'session_id' => $request->session_id

        ]);




        $item = CartItem::where('cart_id',$cart->id)

            ->where('product_id',$request->product_id)

            ->where('product_variant_id',$request->product_variant_id)

            ->first();




        if ($item) {


            $item->update([

                'quantity' => $item->quantity + $request->quantity

            ]);



        } else {



            if ($request->product_variant_id) {


                $variant = ProductVariant::findOrFail(
                    $request->product_variant_id
                );


                $price = $variant->discount_price 
                    ?? $variant->price;



            } else {


                $product = Product::findOrFail(
                    $request->product_id
                );


                $price = $product->discount_price 
                    ?? $product->price;


            }




            CartItem::create([

                'cart_id' => $cart->id,

                'product_id' => $request->product_id,

                'product_variant_id' => $request->product_variant_id,

                'quantity' => $request->quantity,

                'price' => $price

            ]);

        }





        return response()->json([

            'success' => true,

            'message' => 'Product added to cart',

            'data' => Cart::with('items')->find($cart->id)

        ]);

    }





    public function update(Request $request,$id)
    {

        $request->validate([

            'quantity'=>'required|integer|min:1'

        ]);



        $item = CartItem::findOrFail($id);



        $item->update([

            'quantity'=>$request->quantity

        ]);



        return response()->json([

            'success'=>true,

            'message'=>'Cart updated',

            'data'=>$item

        ]);

    }





    public function destroy($id)
    {

        $item = CartItem::findOrFail($id);


        $item->delete();



        return response()->json([

            'success'=>true,

            'message'=>'Item removed'

        ]);

    }


}