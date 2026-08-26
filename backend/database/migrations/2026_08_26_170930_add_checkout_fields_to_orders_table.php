<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('orders', function (Blueprint $table) {
            $table->string('order_number')
                ->nullable()
                ->unique()
                ->after('id');

            $table->json('address_snapshot')
                ->nullable()
                ->after('session_id');

            $table->decimal('discount_total', 15, 2)
                ->default(0)
                ->after('subtotal');

            $table->decimal('shipping_total', 15, 2)
                ->default(0)
                ->after('discount_total');

            $table->string('payment_status')
                ->default('unpaid')
                ->after('total');

            $table->string('order_status')
                ->default('pending')
                ->after('payment_status');
        });

        $orders = DB::table('orders')->get();

        foreach ($orders as $order) {
            DB::table('orders')
                ->where('id', $order->id)
                ->update([
                    'order_number' => 'ORD-' . str_pad(
                        (string) $order->id,
                        8,
                        '0',
                        STR_PAD_LEFT
                    ),

                    'discount_total' => $order->discount ?? 0,
                    'order_status' => $order->status ?? 'pending',
                ]);
        }
    }

    public function down(): void
    {
        Schema::table('orders', function (Blueprint $table) {
            $table->dropUnique(['order_number']);

            $table->dropColumn([
                'order_number',
                'address_snapshot',
                'discount_total',
                'shipping_total',
                'payment_status',
                'order_status',
            ]);
        });
    }
};