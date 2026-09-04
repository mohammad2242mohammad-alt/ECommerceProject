<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('order_items', function (Blueprint $table) {
            $table->string('product_name_snapshot')
                ->nullable()
                ->after('product_name');

            $table->string('sku_snapshot')
                ->nullable()
                ->after('product_name_snapshot');

            $table->decimal('unit_price', 15, 2)
                ->nullable()
                ->after('price');

            $table->decimal('discount_amount', 15, 2)
                ->default(0)
                ->after('unit_price');

            $table->decimal('line_total', 15, 2)
                ->nullable()
                ->after('subtotal');
        });

        $items = DB::table('order_items')->get();

        foreach ($items as $item) {
            DB::table('order_items')
                ->where('id', $item->id)
                ->update([
                    'product_name_snapshot' => $item->product_name,
                    'unit_price' => $item->price,
                    'line_total' => $item->subtotal,
                ]);
        }
    }

    public function down(): void
    {
        Schema::table('order_items', function (Blueprint $table) {
            $table->dropColumn([
                'product_name_snapshot',
                'sku_snapshot',
                'unit_price',
                'discount_amount',
                'line_total',
            ]);
        });
    }
};