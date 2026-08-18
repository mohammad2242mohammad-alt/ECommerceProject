<?php

namespace Database\Seeders;

use App\Models\Category;
use Illuminate\Database\Seeder;

class CategorySeeder extends Seeder
{
    /**
     * اجرای پرکردن داده‌های تستی اولیه برای جدول دسته‌بندی‌ها
     */
    public function run(): void
    {
        // ۱. ایجاد دسته اصلی: کالای دیجیتال
        $digital = Category::create([
            'parent_id' => null,
            'name' => 'کالای دیجیتال',
            'slug' => 'digital-products',
            'description' => 'انواع دستگاه‌های هوشمند و تجهیزات دیجیتال',
            'image' => null,
            'sort_order' => 1,
            'is_active' => true,
        ]);

        // زیردسته‌های کالای دیجیتال
        Category::create([
            'parent_id' => $digital->id,
            'name' => 'گوشی موبایل',
            'slug' => 'mobile-phones',
            'description' => 'انواع گوشی‌های هوشمند اپل، سامسونگ، شیائومی و...',
            'image' => null,
            'sort_order' => 1,
            'is_active' => true,
        ]);

        Category::create([
            'parent_id' => $digital->id,
            'name' => 'لپ‌تاپ و اولترابوک',
            'slug' => 'laptops',
            'description' => 'لپ‌تاپ‌های گیمینگ، مهندسی و اداری',
            'image' => null,
            'sort_order' => 2,
            'is_active' => true,
        ]);

        Category::create([
            'parent_id' => $digital->id,
            'name' => 'هدفون و هندزفری',
            'slug' => 'headphones',
            'description' => 'هدفون‌های بلوتوثی و باسیم',
            'image' => null,
            'sort_order' => 3,
            'is_active' => true,
        ]);

        // ۲. ایجاد دسته اصلی: مد و پوشاک
        $fashion = Category::create([
            'parent_id' => null,
            'name' => 'مد و پوشاک',
            'slug' => 'fashion-clothing',
            'description' => 'انواع لباس، کیف و کفش زنانه و مردانه',
            'image' => null,
            'sort_order' => 2,
            'is_active' => true,
        ]);

        // زیردسته‌های مد و پوشاک
        Category::create([
            'parent_id' => $fashion->id,
            'name' => 'لباس مردانه',
            'slug' => 'men-clothing',
            'description' => 'پیراهن، تیشرت، شلوار و کاپشن مردانه',
            'image' => null,
            'sort_order' => 1,
            'is_active' => true,
        ]);

        Category::create([
            'parent_id' => $fashion->id,
            'name' => 'کفش و کتانی',
            'slug' => 'shoes',
            'description' => 'انواع کفش اسپرت، رسمی و روزمره',
            'image' => null,
            'sort_order' => 2,
            'is_active' => true,
        ]);
    }
}