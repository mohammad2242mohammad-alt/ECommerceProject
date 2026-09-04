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

            $table->foreignId('category_id')
                ->constrained('categories')
                ->cascadeOnDelete();

            $table->string('name');

            $table->string('slug')->unique();

            $table->string('sku')->unique();

            $table->string('short_description')->nullable();

            $table->text('description')->nullable();

            $table->decimal('price', 15, 2);

            $table->decimal('discount_price', 15, 2)->nullable();

            $table->unsignedInteger('stock')->default(0);

            $table->string('status')->default('active');

            $table->decimal('rating_average', 3, 2)->default(0);

            $table->unsignedInteger('rating_count')->default(0);

            $table->timestamps();

            $table->index('category_id');
            $table->index('status');
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('products');
    }
};