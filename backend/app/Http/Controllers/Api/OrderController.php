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
                'required',
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

        $cart = Cart::with([
            'items.product',
            'items.variant',
        ])
            ->where(
                'session_id',
                $validated['session_id']
            )
            ->first();

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
            /*
            |--------------------------------------------------------------------------
            | Final stock / availability check
            |--------------------------------------------------------------------------
            */

            foreach (
                $cart->items as $item
            ) {
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
                            'Product ID ' .
                            $item->product_id .
                            ' is not available.',
                        ],
                    ]);
                }

                if (
                    $item->product_variant_id
                ) {
                    $variant =
                        ProductVariant::lockForUpdate()
                            ->where(
                                'id',
                                $item->product_variant_id
                            )
                            ->where(
                                'product_id',
                                $product->id
                            )
                            ->where(
                                'is_active',
                                true
                            )
                            ->first();

                    if (!$variant) {
                        throw ValidationException::withMessages([
                            'variant' => [
                                'Selected variant for product ID ' .
                                $product->id .
                                ' is not available.',
                            ],
                        ]);
                    }

                    if (
                        $variant->stock <
                        $item->quantity
                    ) {
                        throw ValidationException::withMessages([
                            'stock' => [
                                'Insufficient variant stock for product ID ' .
                                $product->id,
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
                                'Insufficient stock for product ID ' .
                                $product->id,
                            ],
                        ]);
                    }
                }
            }

            /*
            |--------------------------------------------------------------------------
            | Recalculate server-side price
            |--------------------------------------------------------------------------
            */

            $calculation =
                $checkoutService->calculate(
                    $cart,
                    $validated[
                        'coupon_code'
                    ] ?? null,
                    $user->id
                );

            /*
            |--------------------------------------------------------------------------
            | Create order
            |--------------------------------------------------------------------------
            */

            $order = Order::create([
                'user_id' =>
                    $user->id,

                'session_id' =>
                    $validated['session_id'],

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

                    'latitude' =>
                        $address->latitude,

                    'longitude' =>
                        $address->longitude,
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
            | Order items + stock decrement
            |--------------------------------------------------------------------------
            */

            foreach (
                $cart->items as $item
            ) {
                $product =
                    Product::findOrFail(
                        $item->product_id
                    );

                $variant = null;

                if (
                    $item->product_variant_id
                ) {
                    $variant =
                        ProductVariant::findOrFail(
                            $item->product_variant_id
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
                        $item->product_variant_id,

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
            | Coupon usage
            |--------------------------------------------------------------------------
            */

            if (
                $calculation['coupon'] &&
                $calculation['discount'] > 0
            ) {
                CouponUsage::create([
                    'coupon_id' =>
                        $calculation[
                            'coupon'
                        ]->id,

                    'user_id' =>
                        $user->id,

                    'order_id' =>
                        $order->id,

                    'discount_amount' =>
                        $calculation[
                            'discount'
                        ],

                    'created_at' =>
                        now(),
                ]);
            }

            /*
            |--------------------------------------------------------------------------
            | Clear cart
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
            $order = Order::with([
                'items',
                'payment',
            ])
                ->where(
                    'user_id',
                    $request->user()->id
                )
                ->lockForUpdate()
                ->findOrFail($id);

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

            foreach (
                $order->items as $item
            ) {
                if (
                    $item->product_variant_id
                ) {
                    ProductVariant::where(
                        'id',
                        $item->product_variant_id
                    )->increment(
                        'stock',
                        $item->quantity
                    );
                } else {
                    Product::where(
                        'id',
                        $item->product_id
                    )->increment(
                        'stock',
                        $item->quantity
                    );
                }
            }

            if (
                $order->payment &&
                $order->payment->status ===
                    'paid'
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