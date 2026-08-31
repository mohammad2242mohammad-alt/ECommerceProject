<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\Order;
use App\Models\Product;
use App\Models\ProductVariant;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Validation\Rule;

class AdminOrderController extends Controller
{
    private const STATUSES = [
        'pending',
        'confirmed',
        'processing',
        'shipped',
        'delivered',
        'cancelled',
    ];

    public function index(Request $request)
    {
        $query = Order::with('user')
            ->withCount('items')
            ->latest();

        if ($request->filled('q')) {
            $search = trim($request->q);

            $query->where(function ($query) use ($search) {
                $query
                    ->where(
                        'order_number',
                        'like',
                        "%{$search}%"
                    )
                    ->orWhereHas(
                        'user',
                        function ($userQuery) use ($search) {
                            $userQuery
                                ->where(
                                    'name',
                                    'like',
                                    "%{$search}%"
                                )
                                ->orWhere(
                                    'phone',
                                    'like',
                                    "%{$search}%"
                                );
                        }
                    );
            });
        }

        if ($request->filled('order_status')) {
            $query->where(
                'order_status',
                $request->order_status
            );
        }

        if ($request->filled('payment_status')) {
            $query->where(
                'payment_status',
                $request->payment_status
            );
        }

        $orders = $query
            ->paginate(20)
            ->withQueryString();

        return view(
            'admin.orders.index',
            [
                'orders' => $orders,
                'statuses' => self::STATUSES,
            ]
        );
    }

    public function show(Order $order)
    {
        $order->load([
            'user',
            'items.product',
            'items.variant.values.attribute',
            'payment',
        ]);

        return view(
            'admin.orders.show',
            [
                'order' => $order,
                'statuses' => self::STATUSES,
            ]
        );
    }

    public function updateStatus(
        Request $request,
        Order $order
    ) {
        $validated = $request->validate([
            'order_status' => [
                'required',
                Rule::in(self::STATUSES),
            ],
        ]);

        DB::transaction(function () use (
            $order,
            $validated
        ) {
            $order = Order::with([
                'items',
                'payment',
            ])
                ->lockForUpdate()
                ->findOrFail($order->id);

            $newStatus =
                $validated['order_status'];

            $oldStatus =
                $order->order_status;

            if ($oldStatus === $newStatus) {
                return;
            }

            /*
            |--------------------------------------------------------------------------
            | Cancelled orders cannot return to active workflow
            |--------------------------------------------------------------------------
            */

            if (
                $oldStatus === 'cancelled' &&
                $newStatus !== 'cancelled'
            ) {
                abort(
                    422,
                    'Cancelled orders cannot be reopened.'
                );
            }

            /*
            |--------------------------------------------------------------------------
            | Restore stock when admin cancels an order
            |--------------------------------------------------------------------------
            */

            if (
                $newStatus === 'cancelled' &&
                $oldStatus !== 'cancelled'
            ) {
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

                    $order->payment_status =
                        'refunded';
                }
            }

            $order->order_status =
                $newStatus;

            $order->status =
                $newStatus;

            $order->save();
        });

        return back()->with(
            'success',
            'وضعیت سفارش با موفقیت تغییر کرد.'
        );
    }
}