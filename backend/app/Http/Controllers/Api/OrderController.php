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
            ->where('user_id', $request->user()->id)
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
            ->where('user_id', $request->user()->id)
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
            'session_id' => 'required|string',

            'address_id' => [
                'required',
                'integer',
                'exists:addresses,id',
            ],

            'coupon_code' => 'nullable|string',
        ]);

        $user = $request->user();

        $address = Address::where(
            'user_id',
            $user->id
        )->findOrFail($validated['address_id']);

        $cart = Cart::with([
            'items.product',
            'items.variant',
        ])
            ->where(
                'session_id',
                $validated['session_id']
            )
            ->first();

        if (!$cart || $cart->items->isEmpty()) {
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
            $calculation = $checkoutService->calculate(
                $cart,
                $validated['coupon_code'] ?? null,
                $user->id
            );

            foreach ($cart->items as $item) {
                if ($item->product_variant_id) {
                    $variant = ProductVariant::lockForUpdate()
                        ->find($item->product_variant_id);

                    if (
                        !$variant ||
                        $variant->stock < $item->quantity
                    ) {
                        throw ValidationException::withMessages([
                            'stock' => [
                                'Insufficient variant stock for product ID ' .
                                $item->product_id,
                            ],
                        ]);
                    }
                } else {
                    $product = Product::lockForUpdate()
                        ->find($item->product_id);

                    if (
                        !$product ||
                        $product->stock < $item->quantity
                    ) {
                        throw ValidationException::withMessages([
                            'stock' => [
                                'Insufficient stock for product ID ' .
                                $item->product_id,
                            ],
                        ]);
                    }
                }
            }

            $order = Order::create([
                'user_id' => $user->id,

                'session_id' =>
                    $validated['session_id'],

                'order_number' =>
                    'ORD-' .
                    now()->format('YmdHis') .
                    '-' .
                    strtoupper(Str::random(5)),

                'address_snapshot' => [
                    'title' => $address->title,
                    'receiver_name' =>
                        $address->receiver_name,
                    'receiver_phone' =>
                        $address->receiver_phone,
                    'province' => $address->province,
                    'city' => $address->city,
                    'address' => $address->address,
                    'postal_code' => $address->postal_code,
                    'latitude' => $address->latitude,
                    'longitude' => $address->longitude,
                ],

                'status' => 'pending',
                'order_status' => 'pending',

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

                'payment_status' => 'unpaid',
            ]);

            foreach ($cart->items as $item) {
                $product = $item->product;
                $variant = $item->variant;

                $unitPrice = (float) $item->price;
                $lineTotal =
                    $unitPrice * (int) $item->quantity;

                OrderItem::create([
                    'order_id' => $order->id,

                    'product_id' =>
                        $item->product_id,

                    'product_variant_id' =>
                        $item->product_variant_id,

                    'product_name' =>
                        $product->name,

                    'product_name_snapshot' =>
                        $product->name,

                    'sku_snapshot' =>
                        $variant?->sku ?? $product->sku,

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

                if ($item->product_variant_id) {
                    ProductVariant::where(
                        'id',
                        $item->product_variant_id
                    )->decrement(
                        'stock',
                        $item->quantity
                    );
                } else {
                    Product::where(
                        'id',
                        $item->product_id
                    )->decrement(
                        'stock',
                        $item->quantity
                    );
                }
            }

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

                    'created_at' =>
                        now(),
                ]);
            }

            $cart->items()->delete();

            return response()->json([
                'success' => true,
                'message' => 'Order created successfully',
                'data' => $order->load([
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

            foreach ($order->items as $item) {
                if ($item->product_variant_id) {
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
                $order->payment->status === 'paid'
            ) {
                $order->payment->update([
                    'status' => 'refunded',
                ]);

                $order->payment_status = 'refunded';
            }

            $order->order_status = 'cancelled';
            $order->status = 'cancelled';

            $order->save();

            return response()->json([
                'success' => true,
                'message' => 'Order cancelled successfully',
                'data' => $order->fresh()->load([
                    'items',
                    'payment',
                ]),
            ]);
        });
    }
}