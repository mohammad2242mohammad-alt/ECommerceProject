<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Cart;
use App\Services\CheckoutService;
use Illuminate\Http\Request;

class CheckoutController extends Controller
{
    public function calculate(
        Request $request,
        CheckoutService $checkoutService
    ) {
        $validated = $request->validate([
            'session_id' => 'required|string',
            'coupon_code' => 'nullable|string'
        ]);

        $cart = Cart::with('items')
            ->where('session_id', $validated['session_id'])
            ->first();

        if (!$cart || $cart->items->isEmpty()) {
            return response()->json([
                'success' => false,
                'message' => 'Cart is empty',
                'errors' => null
            ], 400);
        }

        $result = $checkoutService->calculate(
            $cart,
            $validated['coupon_code'] ?? null,
            $request->user()?->id
        );

        return response()->json([
            'success' => true,
            'message' => 'Checkout calculated successfully',
            'data' => [
                'subtotal' => $result['subtotal'],
                'discount' => $result['discount'],
                'shipping' => $result['shipping'],
                'total' => $result['total'],

                'coupon' => $result['coupon']
                    ? [
                        'id' => $result['coupon']->id,
                        'code' => $result['coupon']->code,
                        'type' => $result['coupon']->type,
                        'value' => $result['coupon']->value
                    ]
                    : null
            ]
        ]);
    }
}