<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class ProductVariant extends Model
{
    protected $fillable = [
        'product_id',
        'sku',
        'price',
        'discount_price',
        'stock',
        'is_active',
        'status',
    ];

    protected $casts = [
        'price' => 'decimal:2',
        'discount_price' => 'decimal:2',
        'stock' => 'integer',
        'is_active' => 'boolean',
    ];


    public function product()
    {
        return $this->belongsTo(Product::class);
    }


    public function values()
    {
        return $this->hasMany(VariantValue::class);
    }
}
