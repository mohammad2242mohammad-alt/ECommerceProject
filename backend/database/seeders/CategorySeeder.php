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
        $digital = Category::updateOrCreate(
            ['slug' => 'digital-products'],
            [
                'parent_id' => null,
                'name' => 'کالای دیجیتال',
                'description' => 'انواع دستگاه‌های هوشمند و تجهیزات دیجیتال',
                'image' => null,
                'sort_order' => 1,
                'is_active' => true,
            ]
        );

        // زیردسته‌های کالای دیجیتال
        Category::updateOrCreate(
            ['slug' => 'mobile-phones'],
            [
                'parent_id' => $digital->id,
                'name' => 'گوشی موبایل',
                'description' => 'انواع گوشی‌های هوشمند اپل، سامسونگ، شیائومی و...',
                'image' => null,
                'sort_order' => 1,
                'is_active' => true,
            ]
        );

        Category::updateOrCreate(
            ['slug' => 'laptops'],
            [
                'parent_id' => $digital->id,
                'name' => 'لپ‌تاپ و اولترابوک',
                'description' => 'لپ‌تاپ‌های گیمینگ، مهندسی و اداری',
                'image' => null,
                'sort_order' => 2,
                'is_active' => true,
            ]
        );

        Category::updateOrCreate(
            ['slug' => 'headphones'],
            [
                'parent_id' => $digital->id,
                'name' => 'هدفون و هندزفری',
                'description' => 'هدفون‌های بلوتوثی و باسیم',
                'image' => null,
                'sort_order' => 3,
                'is_active' => true,
            ]
        );

        // ۲. ایجاد دسته اصلی: مد و پوشاک
        $fashion = Category::updateOrCreate(
            ['slug' => 'fashion-clothing'],
            [
                'parent_id' => null,
                'name' => 'مد و پوشاک',
                'description' => 'انواع لباس، کیف و کفش زنانه و مردانه',
                'image' => null,
                'sort_order' => 2,
                'is_active' => true,
            ]
        );

        // زیردسته‌های مد و پوشاک
        Category::updateOrCreate(
            ['slug' => 'men-clothing'],
            [
                'parent_id' => $fashion->id,
                'name' => 'لباس مردانه',
                'description' => 'پیراهن، تیشرت، شلوار و کاپشن مردانه',
                'image' => null,
                'sort_order' => 1,
                'is_active' => true,
            ]
        );

        Category::updateOrCreate(
            ['slug' => 'shoes'],
            [
                'parent_id' => $fashion->id,
                'name' => 'کفش و کتانی',
                'description' => 'انواع کفش اسپرت، رسمی و روزمره',
                'image' => null,
                'sort_order' => 2,
                'is_active' => true,
            ]
        );
    }
}
