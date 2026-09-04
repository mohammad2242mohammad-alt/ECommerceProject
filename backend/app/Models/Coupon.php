<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Coupon extends Model
{
    protected $fillable = [
        'code',
        'type',
        'value',
        'minimum_order_amount',
        'maximum_discount',
        'starts_at',
        'ends_at',
        'usage_limit',
        'per_user_limit',
        'is_active',
    ];

    protected $casts = [
        'value' => 'decimal:2',
        'minimum_order_amount' => 'decimal:2',
        'maximum_discount' => 'decimal:2',
        'starts_at' => 'datetime',
        'ends_at' => 'datetime',
        'is_active' => 'boolean',
    ];

    public function setCodeAttribute(?string $value): void
    {
        $this->attributes['code'] = $value === null
            ? null
            : strtoupper(trim($value));
    }

    public function usages()
    {
        return $this->hasMany(CouponUsage::class);
    }
}
