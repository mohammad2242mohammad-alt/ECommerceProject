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