<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Setting;

class SettingController extends Controller
{
    public function index()
    {
        $publicKeys = [
            'shipping_price',
            'free_shipping_threshold',
        ];

        $settings = Setting::query()
            ->whereIn('key', $publicKeys)
            ->get()
            ->mapWithKeys(function ($setting) {
                $value = match ($setting->type) {
                    'number' => (float) $setting->value,
                    'boolean' => filter_var(
                        $setting->value,
                        FILTER_VALIDATE_BOOLEAN
                    ),
                    default => $setting->value,
                };

                return [
                    $setting->key => $value,
                ];
            });

        return response()->json([
            'success' => true,
            'message' => 'Success',
            'data' => $settings,
        ]);
    }
}