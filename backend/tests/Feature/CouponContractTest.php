<?php

namespace Tests\Feature;

use App\Models\Cart;
use App\Models\CartItem;
use App\Models\Category;
use App\Models\Coupon;
use App\Models\Product;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class CouponContractTest extends TestCase
{
    use RefreshDatabase;

    public function test_customer_can_validate_a_percentage_coupon(): void
    {
        $user = User::factory()->create();
        $category = Category::create([
            'name' => 'Coupon category',
            'slug' => 'coupon-category-' . uniqid(),
            'is_active' => true,
        ]);
        $product = Product::create([
            'category_id' => $category->id,
            'name' => 'Coupon product',
            'slug' => 'coupon-product-' . uniqid(),
            'sku' => 'COUPON-' . uniqid(),
            'price' => 1000,
            'stock' => 10,
            'status' => 'active',
        ]);
        $cart = Cart::create(['user_id' => $user->id]);
        CartItem::create([
            'cart_id' => $cart->id,
            'product_id' => $product->id,
            'quantity' => 2,
            'price' => 1000,
        ]);
        Coupon::create([
            'code' => 'SAVE10',
            'type' => 'percentage',
            'value' => 10,
            'is_active' => true,
        ]);

        $this->actingAs($user, 'sanctum')
            ->postJson('/api/coupons/validate', ['code' => ' save10 '])
            ->assertOk()
            ->assertJsonPath('success', true)
            ->assertJsonPath('data.coupon.code', 'SAVE10')
            ->assertJsonPath('data.discount', 200);
    }

    public function test_coupon_validation_rejects_invalid_coupon(): void
    {
        $user = User::factory()->create();
        $category = Category::create([
            'name' => 'Coupon category',
            'slug' => 'coupon-category-' . uniqid(),
            'is_active' => true,
        ]);
        $product = Product::create([
            'category_id' => $category->id,
            'name' => 'Coupon product',
            'slug' => 'coupon-product-' . uniqid(),
            'sku' => 'COUPON-' . uniqid(),
            'price' => 1000,
            'stock' => 10,
            'status' => 'active',
        ]);
        $cart = Cart::create(['user_id' => $user->id]);
        CartItem::create([
            'cart_id' => $cart->id,
            'product_id' => $product->id,
            'quantity' => 1,
            'price' => 1000,
        ]);

        $this->actingAs($user, 'sanctum')
            ->postJson('/api/coupons/validate', ['code' => 'NOT-FOUND'])
            ->assertStatus(422)
            ->assertJsonPath('success', false);
    }

    public function test_coupon_validation_rejects_empty_cart(): void
    {
        $user = User::factory()->create();
        Cart::create(['user_id' => $user->id]);

        $this->actingAs($user, 'sanctum')
            ->postJson('/api/coupons/validate', ['code' => 'SAVE10'])
            ->assertStatus(400)
            ->assertJsonPath('success', false)
            ->assertJsonPath('message', 'Cart is empty');
    }
}
