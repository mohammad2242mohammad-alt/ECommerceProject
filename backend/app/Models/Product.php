<?php

namespace App\Models;
use App\Models\Brand;
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

    protected $casts = [
        'price' => 'decimal:2',
        'discount_price' => 'decimal:2',
        'stock' => 'integer',
        'rating_average' => 'decimal:2',
        'rating_count' => 'integer',
    ];
         public function brand()
        {
             return $this->belongsTo(Brand::class);
        }

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

    public function reviews()
    {
        return $this->hasMany(Review::class);
    }

    public function favorites()
    {
        return $this->hasMany(Favorite::class);
    }
}
