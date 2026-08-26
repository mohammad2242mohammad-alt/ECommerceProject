<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;

class DatabaseSeeder extends Seeder
{
    /**
     * نقطه ورود اجرای تمامی سیدرهای پروژه
     */
    public function run(): void
    {
        // فراخوانی سیدر دسته‌بندی‌ها برای ثبت دیتای پایه
        $this->call([
             CategorySeeder::class,
             ProductSeeder::class,
           ]);
    }
}