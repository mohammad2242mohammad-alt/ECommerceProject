<?php

namespace App\Services;

use App\Models\Cart;
use App\Models\Coupon;
use Illuminate\Validation\ValidationException;

class CheckoutService
{
    public function __construct(
        protected ShippingService $shippingService
    ) {
    }

    public function calculate(
        Cart $cart,
        ?string $couponCode = null,
        ?int $userId = null
    ): array {
        $cart->loadMissing('items');

        if ($cart->items->isEmpty()) {
            throw ValidationException::withMessages([
                'cart' => ['Cart is empty.'],
            ]);
        }

        $subtotal = 0;

        foreach ($cart->items as $item) {
            $subtotal += (float) $item->price * (int) $item->quantity;
        }

        $discount = 0;
        $coupon = null;

        if ($couponCode) {
            $coupon = $this->validateCoupon(
                $couponCode,
                $subtotal,
                $userId
            );

            if ($coupon->type === 'percentage') {
                $discount = $subtotal * ((float) $coupon->value / 100);
            } else {
                $discount = (float) $coupon->value;
            }

            if (
                $coupon->maximum_discount !== null &&
                $discount > (float) $coupon->maximum_discount
            ) {
                $discount = (float) $coupon->maximum_discount;
            }

            $discount = min($discount, $subtotal);
        }

        $afterDiscount = max(0, $subtotal - $discount);

        $shipping = $this->shippingService->calculate(
            $afterDiscount
        );

        $total = $afterDiscount + $shipping;

        return [
            'subtotal' => round($subtotal, 2),
            'discount' => round($discount, 2),
            'shipping' => round($shipping, 2),
            'total' => round($total, 2),
            'coupon' => $coupon,
        ];
    }

    public function validateCoupon(
        string $code,
        float $subtotal,
        ?int $userId = null
    ): Coupon {
        $coupon = Coupon::where('code', $code)
            ->where('is_active', true)
            ->first();

        if (!$coupon) {
            throw ValidationException::withMessages([
                'code' => ['Coupon is invalid.'],
            ]);
        }

        if (
            $coupon->starts_at &&
            now()->lt($coupon->starts_at)
        ) {
            throw ValidationException::withMessages([
                'code' => ['Coupon is not active yet.'],
            ]);
        }

        if (
            $coupon->ends_at &&
            now()->gt($coupon->ends_at)
        ) {
            throw ValidationException::withMessages([
                'code' => ['Coupon has expired.'],
            ]);
        }

        if (
            $coupon->minimum_order_amount !== null &&
            $subtotal < (float) $coupon->minimum_order_amount
        ) {
            throw ValidationException::withMessages([
                'code' => ['Minimum order amount has not been reached.'],
            ]);
        }

        if (
            $coupon->usage_limit !== null &&
            $coupon->usages()->count() >= $coupon->usage_limit
        ) {
            throw ValidationException::withMessages([
                'code' => ['Coupon usage limit has been reached.'],
            ]);
        }

        if (
            $userId &&
            $coupon->per_user_limit !== null &&
            $coupon->usages()
                ->where('user_id', $userId)
                ->count() >= $coupon->per_user_limit
        ) {
            throw ValidationException::withMessages([
                'code' => ['Coupon usage limit for this user has been reached.'],
            ]);
        }

        return $coupon;
    }
}