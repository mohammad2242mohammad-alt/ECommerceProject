<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;

class Category extends Model
{
    use HasFactory;

    // نام فیلدهایی که امکان ثبت یا ویرایش دسته‌جمعی (Mass Assignment) را دارند
    protected $fillable = [
        'parent_id',
        'name',
        'slug',
        'description',
        'image',
        'sort_order',
        'is_active',
    ];

    // تبدیل خودکار نوع داده‌ها در زمان خواندن یا ذخیره در دیتابیس
    protected $casts = [
        'is_active' => 'boolean',
        'sort_order' => 'integer',
    ];

    /**
     * دسته‌بندی والد (در صورت وجود)
     * رابطه: هر زیردسته متعلق به یک دسته والد است.
     */
    public function parent(): BelongsTo
    {
        return $this->belongsTo(Category::class, 'parent_id');
    }

    /**
     * زیردسته‌های این دسته‌بندی
     * رابطه: هر دسته می‌تواند چندین زیردسته داشته باشد.
     */
    public function children(): HasMany
    {
        return $this->hasMany(Category::class, 'parent_id');
    }
}