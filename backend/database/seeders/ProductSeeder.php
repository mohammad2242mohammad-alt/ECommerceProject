<?php

namespace Database\Seeders;

use App\Models\Category;
use App\Models\Product;
use Illuminate\Database\Seeder;

class ProductSeeder extends Seeder
{
    public function run(): void
    {
        // پیدا کردن دسته‌بندی‌های موجود در دیتابیس
        $mobile = Category::where('slug', 'mobile-phones')->first();
        $laptop = Category::where('slug', 'laptops')->first();
        $headphone = Category::where('slug', 'headphones')->first();

        // اگر دسته‌بندی‌ها وجود نداشتند، Seeder متوقف شود.
        if (!$mobile || !$laptop || !$headphone) {
            return;
        }

        Product::updateOrCreate(
            ['slug' => 'samsung-galaxy-a55'],
            [
                'name' => 'Samsung Galaxy A55',
                'description' => 'گوشی موبایل سامسونگ Galaxy A55 با کیفیت بالا',
                'price' => 18000000,
                'discount_price' => 16500000,
                'image' => 'assets/images/a55.png',
                'stock' => 25,
                'is_active' => true,
                'rating' => 4.5,
                'views' => 1250,
                'category_id' => $mobile->id,
            ]
        );

        Product::updateOrCreate(
            ['slug' => 'asus-vivobook'],
            [
                'name' => 'ASUS VivoBook',
                'description' => 'لپ‌تاپ مناسب برای کارهای روزمره و دانشجویی',
                'price' => 32000000,
                'discount_price' => 29900000,
                'image' => 'assets/images/laptop.png',
                'stock' => 12,
                'is_active' => true,
                'rating' => 4.3,
                'views' => 890,
                'category_id' => $laptop->id,
            ]
        );

        Product::updateOrCreate(
            ['slug' => 'wireless-headphone'],
            [
                'name' => 'Wireless Headphone',
                'description' => 'هدفون بی‌سیم با کیفیت صدای عالی',
                'price' => 2500000,
                'discount_price' => 2200000,
                'image' => 'assets/images/headphone.png',
                'stock' => 40,
                'is_active' => true,
                'rating' => 4.7,
                'views' => 2100,
                'category_id' => $headphone->id,
            ]
        );
    }
}