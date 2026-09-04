<?php

namespace App\Services;

use App\Models\Setting;

class ShippingService
{
    public function calculate(float $subtotalAfterDiscount): float
    {
        $shippingPrice = (float) Setting::value(
            'shipping_price',
            0
        );

        $freeShippingThreshold = (float) Setting::value(
            'free_shipping_threshold',
            0
        );

        if (
            $freeShippingThreshold > 0 &&
            $subtotalAfterDiscount >= $freeShippingThreshold
        ) {
            return 0;
        }

        return $shippingPrice;
    }
}