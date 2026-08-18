<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * اجرای مایگریشن و ساخت جدول دسته‌بندی‌ها
     */
    public function up(): void
    {
        Schema::create('categories', function (Blueprint $table) {
            // شناسه یکتای دسته‌بندی
            $table->id();

            // شناسه دسته‌بندی والد برای ایجاد ساختار درختی و زیردسته‌ها
            $table->foreignId('parent_id')
                ->nullable()
                ->constrained('categories')
                ->nullOnDelete();

            // نام دسته‌بندی
            $table->string('name');

            // نام انگلیسی یکتا برای استفاده در آدرس‌های وب (URL)
            $table->string('slug')->unique();

            // توضیحات دسته‌بندی (اختیاری)
            $table->text('description')->nullable();

            // مسیر یا نام فایل تصویر دسته‌بندی (اختیاری)
            $table->string('image')->nullable();

            // ترتیب نمایش دسته‌بندی در منوها و لیست‌ها
            $table->unsignedInteger('sort_order')->default(0);

            // وضعیت فعال یا غیرفعال بودن دسته‌بندی
            $table->boolean('is_active')->default(true);

            // فیلدهای تاریخ ایجاد و آخرین ویرایش
            $table->timestamps();
        });
    }

    /**
     * بازگردانی مایگریشن و حذف جدول دسته‌بندی‌ها
     */
    public function down(): void
    {
        Schema::dropIfExists('categories');
    }
};