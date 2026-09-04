<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        if (!Schema::hasColumn('product_variants', 'status')) {
            Schema::table('product_variants', function (Blueprint $table) {
                $table->string('status')->default('active')->after('is_active');
                $table->index('status');
            });

            DB::table('product_variants')->update([
                'status' => DB::raw("CASE WHEN is_active = 1 THEN 'active' ELSE 'inactive' END"),
            ]);
        }

        if (!Schema::hasColumn('cart_items', 'variant_id')) {
            Schema::table('cart_items', function (Blueprint $table) {
                $table->foreignId('variant_id')
                    ->nullable()
                    ->after('product_variant_id')
                    ->constrained('product_variants')
                    ->nullOnDelete();
                $table->index(['cart_id', 'product_id', 'variant_id']);
            });

            DB::statement('UPDATE cart_items SET variant_id = product_variant_id WHERE product_variant_id IS NOT NULL');
        }

        if (!Schema::hasColumn('order_items', 'variant_id')) {
            Schema::table('order_items', function (Blueprint $table) {
                $table->foreignId('variant_id')
                    ->nullable()
                    ->after('product_variant_id')
                    ->constrained('product_variants')
                    ->nullOnDelete();
            });

            DB::statement('UPDATE order_items SET variant_id = product_variant_id WHERE product_variant_id IS NOT NULL');
        }
    }

    public function down(): void
    {
        if (Schema::hasColumn('order_items', 'variant_id')) {
            Schema::table('order_items', function (Blueprint $table) {
                $table->dropForeign(['variant_id']);
                $table->dropColumn('variant_id');
            });
        }

        if (Schema::hasColumn('cart_items', 'variant_id')) {
            Schema::table('cart_items', function (Blueprint $table) {
                $table->dropForeign(['variant_id']);
                $table->dropIndex(['cart_id', 'product_id', 'variant_id']);
                $table->dropColumn('variant_id');
            });
        }

        if (Schema::hasColumn('product_variants', 'status')) {
            Schema::table('product_variants', function (Blueprint $table) {
                $table->dropIndex(['status']);
                $table->dropColumn('status');
            });
        }
    }
};
