<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Cart;
use App\Services\CheckoutService;
use Illuminate\Http\Request;

class CouponController extends Controller
{
    public function validateCoupon(
        Request $request,
        CheckoutService $checkoutService
    ) {
        $validated = $request->validate([
            'code' => 'required|string|max:50',
            'session_id' => 'nullable|string|max:100',
        ]);

        $cartQuery = Cart::with('items');

        if ($request->user()) {
            $cartQuery->where('user_id', $request->user()->id);
        } elseif (!empty($validated['session_id'])) {
            $cartQuery->where('session_id', $validated['session_id']);
        }

        $cart = $cartQuery->first();

        if (!$cart || $cart->items->isEmpty()) {
            return response()->json([
                'success' => false,
                'message' => 'Cart is empty',
                'errors' => null
            ], 400);
        }

        $result = $checkoutService->calculate(
            $cart,
            strtoupper(trim($validated['code'])),
            $request->user()?->id
        );

        return response()->json([
            'success' => true,
            'message' => 'Coupon validated successfully',
            'data' => [
                'coupon' => [
                    'code' => $result['coupon']->code,
                    'type' => $result['coupon']->type,
                    'value' => $result['coupon']->value
                ],

                'subtotal' => $result['subtotal'],
                'discount' => $result['discount'],
                'shipping' => $result['shipping'],
                'total' => $result['total']
            ]
        ]);
    }
}
