<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('products', function (Blueprint $table) {
            $table->index(
                ['status', 'created_at'],
                'products_status_created_at_index'
            );

            $table->index(
                ['status', 'price'],
                'products_status_price_index'
            );

            $table->index(
                ['status', 'rating_average'],
                'products_status_rating_index'
            );

            $table->index(
                ['category_id', 'status', 'created_at'],
                'products_category_status_created_index'
            );
        });

        Schema::table('orders', function (Blueprint $table) {
            $table->index(
                ['user_id', 'created_at'],
                'orders_user_created_at_index'
            );

            $table->index(
                ['user_id', 'order_status'],
                'orders_user_status_index'
            );

            $table->index(
                'payment_status',
                'orders_payment_status_index'
            );
        });

        Schema::table('carts', function (Blueprint $table) {
            $table->index(
                'session_id',
                'carts_session_id_index'
            );
        });
    }

    public function down(): void
    {
        Schema::table('products', function (Blueprint $table) {
            $table->dropIndex(
                'products_status_created_at_index'
            );

            $table->dropIndex(
                'products_status_price_index'
            );

            $table->dropIndex(
                'products_status_rating_index'
            );

            $table->dropIndex(
                'products_category_status_created_index'
            );
        });

        Schema::table('orders', function (Blueprint $table) {
            $table->dropIndex(
                'orders_user_created_at_index'
            );

            $table->dropIndex(
                'orders_user_status_index'
            );

            $table->dropIndex(
                'orders_payment_status_index'
            );
        });

        Schema::table('carts', function (Blueprint $table) {
            $table->dropIndex(
                'carts_session_id_index'
            );
        });
    }
};