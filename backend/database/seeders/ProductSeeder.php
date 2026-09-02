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

        Product::updateOrCreate(
            ['slug' => 'samsung-galaxy-a55'],
            [
                'category_id' => $mobile->id,
                'name' => 'Samsung Galaxy A55',
                'sku' => 'A55-001',
                'description' => 'گوشی موبایل سامسونگ Galaxy A55',
                'price' => 18000000,
                'discount_price' => 16500000,
                'stock' => 25,
                'status' => 'active',
                'rating_average' => 4.5,
                'rating_count' => 120,
            ]
        );

        Product::updateOrCreate(
            ['slug' => 'asus-vivobook'],
            [
                'category_id' => $laptop->id,
                'name' => 'ASUS VivoBook',
                'sku' => 'ASUS-001',
                'description' => 'لپ تاپ ایسوس',
                'price' => 32000000,
                'discount_price' => 29900000,
                'stock' => 12,
                'status' => 'active',
                'rating_average' => 4.3,
                'rating_count' => 80,
            ]
        );

        Product::updateOrCreate(
            ['slug' => 'wireless-headphone'],
            [
                'category_id' => $headphone->id,
                'name' => 'Wireless Headphone',
                'sku' => 'HEAD-001',
                'description' => 'هدفون بی سیم',
                'price' => 2500000,
                'discount_price' => 2200000,
                'stock' => 40,
                'status' => 'active',
                'rating_average' => 4.7,
                'rating_count' => 200,
            ]
        );
    }
}