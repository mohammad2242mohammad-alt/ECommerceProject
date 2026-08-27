<?php

namespace Database\Seeders;

use App\Models\Category;
use App\Models\Product;
use Illuminate\Database\Seeder;

class ProductSeeder extends Seeder
{
    public function run(): void
    {
        $mobile = Category::where('slug', 'mobile-phones')->first();
        $laptop = Category::where('slug', 'laptops')->first();
        $headphone = Category::where('slug', 'headphones')->first();

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
                'stock' => 25,
                'status' => 'active',
                'rating_average' => 4.5,
                'rating_count' => 1250,
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
                'stock' => 12,
                'status' => 'active',
                'rating_average' => 4.3,
                'rating_count' => 890,
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
                'stock' => 40,
                'status' => 'active',
                'rating_average' => 4.7,
                'rating_count' => 2100,
                'category_id' => $headphone->id,
            ]
        );
    }
}
