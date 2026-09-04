<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Order extends Model
{
    protected $fillable = [
        'user_id',
        'session_id',
        'order_number',
        'address_snapshot',

        'status',

        'subtotal',
        'discount',
        'discount_total',
        'shipping_total',
        'total',

        'payment_status',
        'order_status',
    ];

    protected $casts = [
        'address_snapshot' => 'array',
        'subtotal' => 'decimal:2',
        'discount' => 'decimal:2',
        'discount_total' => 'decimal:2',
        'shipping_total' => 'decimal:2',
        'total' => 'decimal:2',
    ];

    public function user()
    {
        return $this->belongsTo(User::class);
    }

    public function items()
    {
        return $this->hasMany(OrderItem::class);
    }

    public function payment()
    {
        return $this->hasOne(Payment::class);
    }

    public function couponUsage()
    {
        return $this->hasOne(CouponUsage::class);
    }
}
