<?php

namespace Database\Seeders;

use App\Models\Banner;
use App\Models\Coupon;
use App\Models\Setting;
use App\Models\User;
use Illuminate\Database\Seeder;

class DemoStoreSeeder extends Seeder
{
    public function run(): void
    {
        User::updateOrCreate(
            ['phone' => '09120000001'],
            [
                'name' => 'مدیر فروشگاه',
                'password' => 'password',
                'role' => 'admin',
                'is_active' => true,
            ]
        );

        User::updateOrCreate(
            ['phone' => '09120000002'],
            [
                'name' => 'کاربر آزمایشی',
                'password' => 'password',
                'role' => 'customer',
                'is_active' => true,
            ]
        );

        Coupon::updateOrCreate(
            ['code' => 'WELCOME10'],
            [
                'type' => 'percentage',
                'value' => 10,
                'minimum_order_amount' => 0,
                'maximum_discount' => 1000000,
                'usage_limit' => null,
                'per_user_limit' => 1,
                'is_active' => true,
            ]
        );

        Banner::updateOrCreate(
            ['title' => 'پیشنهاد ویژه فروشگاه'],
            [
                'image' => 'banners/demo-store.jpg',
                'link_type' => 'category',
                'link_value' => 'digital-products',
                'sort_order' => 1,
                'is_active' => true,
            ]
        );

        Setting::updateOrCreate(
            ['key' => 'shipping_price'],
            ['value' => '100000', 'type' => 'number']
        );

        Setting::updateOrCreate(
            ['key' => 'free_shipping_threshold'],
            ['value' => '10000000', 'type' => 'number']
        );
    }
}
