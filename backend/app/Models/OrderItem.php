<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class OrderItem extends Model
{
    protected $fillable = [
        'order_id',
        'product_id',
        'product_variant_id',
        'variant_id',

        'product_name',

        'product_name_snapshot',
        'sku_snapshot',

        'quantity',

        'price',
        'unit_price',

        'discount_amount',

        'subtotal',
        'line_total',
    ];

    protected $casts = [
        'price' => 'decimal:2',
        'unit_price' => 'decimal:2',
        'discount_amount' => 'decimal:2',
        'subtotal' => 'decimal:2',
        'line_total' => 'decimal:2',
    ];

    public function order()
    {
        return $this->belongsTo(Order::class);
    }

    public function product()
    {
        return $this->belongsTo(Product::class);
    }

    public function variant()
    {
        return $this->belongsTo(
            ProductVariant::class,
            'variant_id'
        );
    }
}
