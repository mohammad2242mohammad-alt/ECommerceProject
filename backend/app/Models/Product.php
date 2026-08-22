<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Product extends Model
{
    protected $fillable = [
        'category_id',
        'name',
        'slug',
        'sku',
        'short_description',
        'description',
        'price',
        'discount_price',
        'stock',
        'status',
    ];


    public function category()
    {
        return $this->belongsTo(Category::class);
    }


    public function images()
    {
        return $this->hasMany(ProductImage::class);
    }


    public function attributeValues()
    {
        return $this->hasMany(ProductAttributeValue::class);
    }


    public function variants()
    {
        return $this->hasMany(ProductVariant::class);
    }
}