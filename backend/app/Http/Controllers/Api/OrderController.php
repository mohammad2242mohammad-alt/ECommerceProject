<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Address;
use App\Models\Cart;
use App\Models\CouponUsage;
use App\Models\Order;
use App\Models\OrderItem;
use App\Models\Product;
use App\Models\ProductVariant;
use App\Services\CheckoutService;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Str;
use Illuminate\Validation\ValidationException;

class OrderController extends Controller
{
    public function index(Request $request)
    {
        $orders = Order::with([
            'items',
            'payment',
        ])
            ->where(
                'user_id',
                $request->user()->id
            )
            ->latest()
            ->paginate(15);

        return response()->json([
            'success' => true,
            'message' => 'Success',
            'data' => $orders,
        ]);
    }


    public function show(
        Request $request,
        int $id
    ) {
        $order = Order::with([
            'items',
            'payment',
        ])
            ->where(
                'user_id',
                $request->user()->id
            )
            ->findOrFail($id);

        $this->authorize('view', $order);

        return response()->json([
            'success' => true,
            'message' => 'Success',
            'data' => $order,
        ]);
    }


    public function store(
        Request $request,
        CheckoutService $checkoutService
    ) {

        $validated = $request->validate([

            'session_id' => [
                'nullable',
                'string',
                'max:100',
            ],

            'address_id' => [
                'required',
                'integer',
                'exists:addresses,id',
            ],

            'coupon_code' => [
                'nullable',
                'string',
            ],

        ]);


        $user = $request->user();


        $address = Address::where(
            'user_id',
            $user->id
        )->findOrFail(
            $validated['address_id']
        );


        /*
        |--------------------------------------------------------------------------
        | Find Cart
        |--------------------------------------------------------------------------
        */

        $cartQuery = Cart::with([
            'items.product',
            'items.variant',
        ]);


        if ($user) {

            $cartQuery->where(
                'user_id',
                $user->id
            );

        } else {

            $cartQuery->where(
                'session_id',
                $validated['session_id']
            );

        }


        $cart = $cartQuery->first();


        if (
            !$cart ||
            $cart->items->isEmpty()
        ) {

            return response()->json([
                'success' => false,
                'message' => 'Cart is empty',
                'errors' => null,
            ], 400);

        }



        return DB::transaction(function () use (
            $user,
            $address,
            $cart,
            $validated,
            $checkoutService
        ) {


            foreach ($cart->items as $item) {


                $product =
                    Product::lockForUpdate()
                        ->where(
                            'id',
                            $item->product_id
                        )
                        ->where(
                            'status',
                            'active'
                        )
                        ->first();


                if (!$product) {

                    throw ValidationException::withMessages([
                        'product' => [
                            'Product is not available.',
                        ],
                    ]);

                }



                $variantId = $item->variant_id ?? $item->product_variant_id;

                if ($variantId) {


                    $variant =
                        ProductVariant::lockForUpdate()
                            ->where(
                                'id',
                                $variantId
                            )
                            ->where(
                                'product_id',
                                $product->id
                            )
                            ->where('status', 'active')
                            ->first();



                    if (!$variant) {

                        throw ValidationException::withMessages([
                            'variant' => [
                                'Variant is not available.',
                            ],
                        ]);

                    }



                    if (
                        $variant->stock <
                        $item->quantity
                    ) {

                        throw ValidationException::withMessages([
                            'stock' => [
                                'Insufficient stock.',
                            ],
                        ]);

                    }


                } else {


                    if (
                        $product->stock <
                        $item->quantity
                    ) {

                        throw ValidationException::withMessages([
                            'stock' => [
                                'Insufficient stock.',
                            ],
                        ]);

                    }

                }

            }



            $calculation =
                $checkoutService->calculate(
                    $cart,
                    $validated['coupon_code'] ?? null,
                    $user->id
                );



            $order = Order::create([

                'user_id' =>
                    $user->id,

                'session_id' =>
                    $validated['session_id'] ?? null,

                'order_number' =>
                    'ORD-' .
                    now()->format('YmdHis') .
                    '-' .
                    strtoupper(
                        Str::random(5)
                    ),

                'address_snapshot' => [

                    'title' =>
                        $address->title,

                    'receiver_name' =>
                        $address->receiver_name,

                    'receiver_phone' =>
                        $address->receiver_phone,

                    'province' =>
                        $address->province,

                    'city' =>
                        $address->city,

                    'address' =>
                        $address->address,

                    'postal_code' =>
                        $address->postal_code,

                ],


                'status' =>
                    'pending',

                'order_status' =>
                    'pending',


                'subtotal' =>
                    $calculation['subtotal'],

                'discount' =>
                    $calculation['discount'],

                'discount_total' =>
                    $calculation['discount'],

                'shipping_total' =>
                    $calculation['shipping'],

                'total' =>
                    $calculation['total'],

                'payment_status' =>
                    'unpaid',

            ]);
                        /*
            |--------------------------------------------------------------------------
            | Create Order Items + Decrease Stock
            |--------------------------------------------------------------------------
            */

            foreach ($cart->items as $item) {


                $product =
                    Product::findOrFail(
                        $item->product_id
                    );


                $variant = null;


                $variantId = $item->variant_id ?? $item->product_variant_id;

                if ($variantId) {

                    $variant =
                        ProductVariant::findOrFail(
                            $variantId
                        );

                }


                $unitPrice =
                    (float) $item->price;


                $lineTotal =
                    $unitPrice *
                    (int) $item->quantity;



                OrderItem::create([

                    'order_id' =>
                        $order->id,


                    'product_id' =>
                        $item->product_id,


                    'product_variant_id' =>
                        $variantId,

                    'variant_id' =>
                        $variantId,


                    'product_name' =>
                        $product->name,


                    'product_name_snapshot' =>
                        $product->name,


                    'sku_snapshot' =>
                        $variant?->sku
                        ?? $product->sku,


                    'quantity' =>
                        $item->quantity,


                    'price' =>
                        $unitPrice,


                    'unit_price' =>
                        $unitPrice,


                    'discount_amount' =>
                        0,


                    'subtotal' =>
                        $lineTotal,


                    'line_total' =>
                        $lineTotal,

                ]);



                if ($variant) {

                    $variant->decrement(
                        'stock',
                        $item->quantity
                    );

                } else {

                    $product->decrement(
                        'stock',
                        $item->quantity
                    );

                }

            }



            /*
            |--------------------------------------------------------------------------
            | Coupon Usage
            |--------------------------------------------------------------------------
            */

            if (
                $calculation['coupon'] &&
                $calculation['discount'] > 0
            ) {


                CouponUsage::create([

                    'coupon_id' =>
                        $calculation['coupon']->id,


                    'user_id' =>
                        $user->id,


                    'order_id' =>
                        $order->id,


                    'discount_amount' =>
                        $calculation['discount'],

                ]);

            }



            /*
            |--------------------------------------------------------------------------
            | Clear Cart
            |--------------------------------------------------------------------------
            */

            $cart->items()->delete();



            return response()->json([

                'success' => true,


                'message' =>
                    'Order created successfully',


                'data' =>
                    $order->load([
                        'items',
                        'payment',
                    ]),


            ], 201);


        });

    }



    public function cancel(
        Request $request,
        int $id
    ) {


        return DB::transaction(function () use (
            $request,
            $id
        ) {


            $order =
                Order::with([
                    'items',
                    'payment',
                ])
                ->where(
                    'user_id',
                    $request->user()->id
                )
                ->lockForUpdate()
                ->findOrFail($id);

            $this->authorize('cancel', $order);



            if (
                !in_array(
                    $order->order_status,
                    [
                        'pending',
                        'confirmed',
                    ],
                    true
                )
            ) {


                return response()->json([

                    'success' => false,

                    'message' =>
                        'This order cannot be cancelled',

                    'errors' => null,

                ], 422);


            }



            foreach ($order->items as $item) {


                $variantId = $item->variant_id ?? $item->product_variant_id;

                if ($variantId) {


                    ProductVariant::where(
                        'id',
                        $variantId
                    )
                    ->increment(
                        'stock',
                        $item->quantity
                    );


                } else {


                    Product::where(
                        'id',
                        $item->product_id
                    )
                    ->increment(
                        'stock',
                        $item->quantity
                    );


                }

            }



            if (
                $order->payment &&
                $order->payment->status === 'paid'
            ) {


                $order->payment->update([

                    'status' =>
                        'refunded',

                ]);


                $order->payment_status =
                    'refunded';

            }



            $order->order_status =
                'cancelled';


            $order->status =
                'cancelled';


            $order->save();



            return response()->json([

                'success' => true,

                'message' =>
                    'Order cancelled successfully',


                'data' =>
                    $order
                        ->fresh()
                        ->load([
                            'items',
                            'payment',
                        ]),

            ]);

        });

    }

}
