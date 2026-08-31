<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Order;
use App\Services\PaymentService;
use Illuminate\Http\Request;

class PaymentController extends Controller
{
    public function start(
        Request $request,
        int $orderId,
        PaymentService $paymentService
    ) {
        $validated = $request->validate([
            'simulate' => [
                'nullable',
                'in:success,failure',
            ],
        ]);

        $order = Order::with('payment')
            ->where(
                'user_id',
                $request->user()->id
            )
            ->findOrFail($orderId);

        if (
            $order->order_status ===
            'cancelled'
        ) {
            return response()->json([
                'success' => false,

                'message' =>
                    'Cancelled order cannot be paid',

                'errors' => null,
            ], 422);
        }

        if (
            $order->payment_status === 'paid' ||
            $order->payment?->status === 'paid'
        ) {
            return response()->json([
                'success' => false,

                'message' =>
                    'Order has already been paid',

                'errors' => null,
            ], 422);
        }

        $payment =
            $paymentService->start(
                $order,
                $validated['simulate']
                    ?? 'success'
            );

        return response()->json([
            'success' => true,

            'message' =>
                'Payment processed successfully',

            'data' => [
                'payment' =>
                    $payment,

                'order' =>
                    $order->fresh(),
            ],
        ]);
    }

    public function status(
        Request $request,
        int $orderId
    ) {
        $order = Order::with(
            'payment'
        )
            ->where(
                'user_id',
                $request->user()->id
            )
            ->findOrFail($orderId);

        return response()->json([
            'success' => true,
            'message' => 'Success',

            'data' => [
                'order_id' =>
                    $order->id,

                'order_number' =>
                    $order->order_number,

                'payment_status' =>
                    $order->payment_status,

                'payment' =>
                    $order->payment,
            ],
        ]);
    }
}