<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Cart;
use App\Models\Order;
use App\Models\OrderItem;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;


class OrderController extends Controller
{


    public function store(Request $request)
    {


        $request->validate([
            'session_id' => 'required'
        ]);



        $cart = Cart::with('items')
            ->where('session_id', $request->session_id)
            ->first();



        if (!$cart || $cart->items->count() == 0) {


            return response()->json([

                'success' => false,

                'message' => 'Cart is empty'

            ],400);

        }




        DB::beginTransaction();



        try {


            $subtotal = 0;



            foreach($cart->items as $item){

                $subtotal += $item->price * $item->quantity;

            }




            $order = Order::create([


                'user_id' => null,

                'session_id' => $request->session_id,

                'status' => 'pending',

                'subtotal' => $subtotal,

                'discount' => 0,

                'total' => $subtotal


            ]);





            foreach($cart->items as $item){


                OrderItem::create([


                    'order_id' => $order->id,


                    'product_id' => $item->product_id,


                    'product_variant_id' => $item->product_variant_id,


                    'product_name' => $item->product->name,


                    'quantity' => $item->quantity,


                    'price' => $item->price,


                    'subtotal' => $item->price * $item->quantity


                ]);


            }




            $cart->items()->delete();



            DB::commit();



            return response()->json([


                'success' => true,


                'message' => 'Order created successfully',


                'data' => $order->load('items')


            ]);



        } catch(\Exception $e){


            DB::rollBack();


            return response()->json([

                'success'=>false,

                'message'=>$e->getMessage()

            ],500);


        }



    }


}