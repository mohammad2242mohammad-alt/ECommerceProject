<?php

namespace Database\Seeders;

use App\Models\Category;
use App\Models\Product;
use App\Models\ProductImage;
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

        $products = [
            [
                'category' => $mobile,
                'name' => 'Samsung Galaxy A55',
                'slug' => 'samsung-galaxy-a55',
                'sku' => 'DEMO-MOB-A55',
                'description' => 'گوشی موبایل سامسونگ Galaxy A55 با کیفیت بالا',
                'price' => 18000000,
                'discount_price' => 16500000,
                'stock' => 25,
                'image' => 'products/demo/a55.png',
            ],
            [
                'category' => $laptop,
                'name' => 'ASUS VivoBook',
                'slug' => 'asus-vivobook',
                'sku' => 'DEMO-LAP-VIVOBOOK',
                'description' => 'لپ‌تاپ مناسب برای کارهای روزمره و دانشجویی',
                'price' => 32000000,
                'discount_price' => 29900000,
                'stock' => 12,
                'image' => 'products/demo/laptop.png',
            ],
            [
                'category' => $headphone,
                'name' => 'Wireless Headphone',
                'slug' => 'wireless-headphone',
                'sku' => 'DEMO-HDP-WIRELESS',
                'description' => 'هدفون بی‌سیم با کیفیت صدای عالی',
                'price' => 2500000,
                'discount_price' => 2200000,
                'stock' => 40,
                'image' => 'products/demo/headphone.png',
            ],
        ];

        foreach ($products as $data) {
            $product = Product::updateOrCreate(
                ['slug' => $data['slug']],
                [
                    'category_id' => $data['category']->id,
                    'name' => $data['name'],
                    'sku' => $data['sku'],
                    'short_description' => $data['description'],
                    'description' => $data['description'],
                    'price' => $data['price'],
                    'discount_price' => $data['discount_price'],
                    'stock' => $data['stock'],
                    'status' => 'active',
                ]
            );

            ProductImage::updateOrCreate(
                [
                    'product_id' => $product->id,
                    'path' => $data['image'],
                ],
                [
                    'alt_text' => $data['name'],
                    'sort_order' => 0,
                    'is_primary' => true,
                ]
            );
        }
    }
}
