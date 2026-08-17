<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('products', function (Blueprint $table) {
            $table->id();

            // اطلاعات اصلی محصول
            $table->string('name');
            $table->string('slug')->unique();
            $table->text('description')->nullable();

            // قیمت
            $table->decimal('price', 15, 2);
            $table->decimal('discount_price', 15, 2)->nullable();

            // تصویر اصلی
            $table->string('image')->nullable();

            // موجودی
            $table->unsignedInteger('stock')->default(0);

            // وضعیت محصول
            $table->boolean('is_active')->default(true);

            // امتیاز و بازدید
            $table->decimal('rating', 2, 1)->default(0);
            $table->unsignedInteger('views')->default(0);

            // ارتباط با دسته‌بندی
            $table->foreignId('category_id')
                ->constrained('categories')
                ->cascadeOnDelete();

            $table->timestamps();

            // ایندکس‌ها
            $table->index('is_active');
            $table->index('category_id');
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('products');
    }
};