<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class CategoryAttribute extends Model
{
    protected $fillable = [
        'category_id',
        'name',
        'slug',
        'type',
        'is_required',
        'sort_order',
    ];


    public function category()
    {
        return $this->belongsTo(Category::class);
    }


    public function values()
    {
        return $this->hasMany(ProductAttributeValue::class);
    }

    public function variantValues()
    {
        return $this->hasMany(VariantValue::class);
    }
}
