<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class VariantValue extends Model
{
    protected $table = 'product_variant_values';

    protected $fillable = [
        'product_variant_id',
        'category_attribute_id',
        'value',
    ];


    public function variant()
    {
        return $this->belongsTo(ProductVariant::class, 'product_variant_id');
    }


    public function attribute()
    {
        return $this->belongsTo(CategoryAttribute::class, 'category_attribute_id');
    }
}
