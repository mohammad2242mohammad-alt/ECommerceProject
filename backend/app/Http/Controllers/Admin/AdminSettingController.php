<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\Setting;
use Illuminate\Http\Request;

class AdminSettingController extends Controller
{
    public function index()
    {
        return view(
            'admin.settings.index',
            [
                'shippingPrice' =>
                    Setting::value(
                        'shipping_price',
                        0
                    ),

                'freeShippingThreshold' =>
                    Setting::value(
                        'free_shipping_threshold',
                        0
                    ),
            ]
        );
    }

    public function update(Request $request)
    {
        $validated = $request->validate([
            'shipping_price' => [
                'required',
                'numeric',
                'min:0',
            ],

            'free_shipping_threshold' => [
                'required',
                'numeric',
                'min:0',
            ],
        ]);

        Setting::updateOrCreate(
            [
                'key' =>
                    'shipping_price',
            ],
            [
                'value' =>
                    $validated[
                        'shipping_price'
                    ],

                'type' =>
                    'number',
            ]
        );

        Setting::updateOrCreate(
            [
                'key' =>
                    'free_shipping_threshold',
            ],
            [
                'value' =>
                    $validated[
                        'free_shipping_threshold'
                    ],

                'type' =>
                    'number',
            ]
        );

        return back()->with(
            'success',
            'تنظیمات ارسال با موفقیت ذخیره شد.'
        );
    }
}