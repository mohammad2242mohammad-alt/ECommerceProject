<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Foundation\Auth\User as Authenticatable;
use Illuminate\Notifications\Notifiable;
use Laravel\Sanctum\HasApiTokens;

class User extends Authenticatable
{
    use HasApiTokens, HasFactory, Notifiable;

    /**
     * Fields that may be mass assigned.
     *
     * @var array<int, string>
     */
    protected $fillable = [
        'phone',
        'password',
        'role',
        'name',
        'is_active',
    ];

    /**
     * Fields hidden from API responses.
     *
     * @var array<int, string>
     */
    protected $hidden = [
        'password',
    ];

    /**
     * Attribute casting.
     */
    protected function casts(): array
    {
        return [
            'password' => 'hashed',
            'is_active' => 'boolean',
        ];
    }

    /**
     * User's shopping cart.
     */
    public function cart()
    {
        return $this->hasOne(Cart::class);
    }

    /**
     * User's orders.
     */
    public function orders()
    {
        return $this->hasMany(Order::class);
    }
}