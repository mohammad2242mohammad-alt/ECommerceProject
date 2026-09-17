<?php

namespace Tests\Feature;

use App\Models\CartItem;
use App\Models\Address;
use App\Models\Category;
use App\Models\Coupon;
use App\Models\Product;
use App\Models\Setting;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class StoreContractTest extends TestCase
{
    use RefreshDatabase;

    public function test_registration_matches_the_api_contract(): void
    {
        $response = $this->postJson('/api/auth/register', [
            'phone' => '09123334455',
            'password' => 'secret123',
            'password_confirmation' => 'secret123',
        ]);

        $response
            ->assertCreated()
            ->assertJsonPath('success', true)
            ->assertJsonStructure([
                'success',
                'message',
                'data' => ['user', 'token'],
            ])
            ->assertJsonMissingPath('data.user.password');
    }

    public function test_customer_can_login_view_profile_and_logout(): void
    {
        $user = User::factory()->create([
            'phone' => '09121112233',
            'password' => 'secret123',
            'is_active' => true,
        ]);

        $login = $this->postJson('/api/auth/login', [
            'phone' => '09121112233',
            'password' => 'secret123',
        ]);

        $login->assertOk()->assertJsonStructure(['data' => ['user', 'token']]);
        $token = $login->json('data.token');

        $this->withToken($token)
            ->getJson('/api/auth/me')
            ->assertOk()
            ->assertJsonPath('data.user.id', $user->id);

        $this->withToken($token)
            ->postJson('/api/auth/logout')
            ->assertOk()
            ->assertJsonPath('success', true);
    }

    public function test_authenticated_customer_can_clear_the_cart(): void
    {
        $user = User::factory()->create();
        $category = Category::create([
            'name' => 'Test category',
            'slug' => 'test-category',
            'is_active' => true,
        ]);
        $product = Product::create([
            'category_id' => $category->id,
            'name' => 'Test product',
            'slug' => 'test-product',
            'sku' => 'TEST-PRODUCT-001',
            'price' => 100,
            'stock' => 5,
            'status' => 'active',
        ]);

        $this->actingAs($user, 'sanctum')
            ->postJson('/api/cart/items', [
                'product_id' => $product->id,
                'quantity' => 1,
            ])
            ->assertOk();

        $this->actingAs($user, 'sanctum')
            ->deleteJson('/api/cart')
            ->assertOk()
            ->assertJsonPath('success', true);

        $this->assertDatabaseCount('cart_items', 0);
    }

    public function test_cart_rejects_quantity_above_available_stock(): void
    {
        $user = User::factory()->create();
        $category = Category::create([
            'name' => 'Stock category',
            'slug' => 'stock-category',
            'is_active' => true,
        ]);
        $product = Product::create([
            'category_id' => $category->id,
            'name' => 'Limited product',
            'slug' => 'limited-product',
            'sku' => 'LIMITED-001',
            'price' => 100,
            'stock' => 2,
            'status' => 'active',
        ]);

        $this->actingAs($user, 'sanctum')
            ->postJson('/api/cart/items', [
                'product_id' => $product->id,
                'quantity' => 3,
            ])
            ->assertStatus(422);
    }

    public function test_order_creation_decreases_stock_and_clears_cart(): void
    {
        [$user, $product] = $this->makeProductWithStock(5, 'ORDER-001');
        $address = $this->makeAddress($user);

        $this->actingAs($user, 'sanctum')
            ->postJson('/api/cart/items', [
                'product_id' => $product->id,
                'quantity' => 2,
            ])
            ->assertOk();

        $response = $this->actingAs($user, 'sanctum')
            ->postJson('/api/orders', ['address_id' => $address->id]);

        $response->assertCreated()->assertJsonPath('success', true);

        $this->assertDatabaseHas('products', [
            'id' => $product->id,
            'stock' => 3,
        ]);
        $this->assertDatabaseCount('cart_items', 0);
        $this->assertDatabaseHas('orders', [
            'user_id' => $user->id,
            'order_status' => 'pending',
            'payment_status' => 'unpaid',
        ]);
    }

    public function test_paid_order_cancellation_refunds_and_restores_stock(): void
    {
        [$user, $product] = $this->makeProductWithStock(5, 'PAYMENT-001');
        $address = $this->makeAddress($user);

        $this->actingAs($user, 'sanctum')
            ->postJson('/api/cart/items', [
                'product_id' => $product->id,
                'quantity' => 2,
            ])
            ->assertOk();

        $orderResponse = $this->actingAs($user, 'sanctum')
            ->postJson('/api/orders', ['address_id' => $address->id])
            ->assertCreated();

        $orderId = $orderResponse->json('data.id');

        $this->actingAs($user, 'sanctum')
            ->postJson("/api/payments/{$orderId}/start", ['simulate' => 'success'])
            ->assertOk()
            ->assertJsonPath('data.payment.status', 'paid');

        $this->actingAs($user, 'sanctum')
            ->postJson("/api/orders/{$orderId}/cancel")
            ->assertOk()
            ->assertJsonPath('data.order_status', 'cancelled')
            ->assertJsonPath('data.payment_status', 'refunded');

        $this->assertDatabaseHas('products', [
            'id' => $product->id,
            'stock' => 5,
        ]);
        $this->assertDatabaseHas('payments', [
            'order_id' => $orderId,
            'status' => 'refunded',
        ]);
    }

    public function test_successful_payment_marks_order_as_paid_and_confirmed(): void
    {
        [$user, $product] = $this->makeProductWithStock(5, 'PAYMENT-002');
        $address = $this->makeAddress($user);

        $this->actingAs($user, 'sanctum')
            ->postJson('/api/cart/items', [
                'product_id' => $product->id,
                'quantity' => 2,
            ])
            ->assertOk();

        $orderResponse = $this->actingAs($user, 'sanctum')
            ->postJson('/api/orders', [
                'address_id' => $address->id,
            ])
            ->assertCreated();

        $orderId = $orderResponse->json('data.id');

        $this->actingAs($user, 'sanctum')
            ->postJson("/api/payments/{$orderId}/start", [
                'simulate' => 'success',
            ])
            ->assertOk()
            ->assertJsonPath('success', true)
            ->assertJsonPath('data.payment.status', 'paid')
            ->assertJsonPath('data.order.payment_status', 'paid')
            ->assertJsonPath('data.order.order_status', 'confirmed');

        $this->assertDatabaseHas('payments', [
            'order_id' => $orderId,
            'status' => 'paid',
            'gateway' => 'mock',
        ]);

        $this->assertDatabaseHas('orders', [
            'id' => $orderId,
            'payment_status' => 'paid',
            'order_status' => 'confirmed',
        ]);

        $this->assertDatabaseMissing('payments', [
            'order_id' => $orderId,
            'transaction_reference' => null,
        ]);
    }

    public function test_failed_payment_marks_payment_failed_and_order_stays_pending(): void
    {
        [$user, $product] = $this->makeProductWithStock(5, 'PAYMENT-003');
        $address = $this->makeAddress($user);

        $this->actingAs($user, 'sanctum')
            ->postJson('/api/cart/items', [
                'product_id' => $product->id,
                'quantity' => 2,
            ])
            ->assertOk();

        $orderResponse = $this->actingAs($user, 'sanctum')
            ->postJson('/api/orders', [
                'address_id' => $address->id,
            ])
            ->assertCreated();

        $orderId = $orderResponse->json('data.id');

        $this->actingAs($user, 'sanctum')
            ->postJson("/api/payments/{$orderId}/start", [
                'simulate' => 'failure',
            ])
            ->assertOk()
            ->assertJsonPath('success', true)
            ->assertJsonPath('data.payment.status', 'failed')
            ->assertJsonPath('data.order.payment_status', 'failed')
            ->assertJsonPath('data.order.order_status', 'pending');

        $this->assertDatabaseHas('payments', [
            'order_id' => $orderId,
            'status' => 'failed',
            'gateway' => 'mock',
        ]);

        $this->assertDatabaseHas('orders', [
            'id' => $orderId,
            'payment_status' => 'failed',
            'order_status' => 'pending',
        ]);
    }

    public function test_customer_cannot_view_another_customers_order(): void
    {
        $user = User::factory()->create();
        $otherUser = User::factory()->create();
        $address = $this->makeAddress($otherUser);
        $order = $this->makeOrder($otherUser, $address);

        $this->actingAs($user, 'sanctum')
            ->getJson("/api/orders/{$order->id}")
            ->assertForbidden();
    }

    public function test_non_admin_cannot_access_admin_api(): void
    {
        $user = User::factory()->create(['role' => 'customer']);

        $this->actingAs($user, 'sanctum')
            ->getJson('/api/admin/banners')
            ->assertForbidden();
    }

    public function test_admin_can_open_the_banner_management_screen(): void
    {
        $admin = User::factory()->create(['role' => 'admin']);

        $this->actingAs($admin, 'sanctum')
            ->getJson('/api/admin/banners')
            ->assertOk()
            ->assertJsonPath('success', true);
    }

    public function test_customer_can_update_cart_item_quantity(): void
    {
        [$user, $product] = $this->makeProductWithStock(5, 'CART-UPDATE-001');

        $this->actingAs($user, 'sanctum')
            ->postJson('/api/cart/items', [
                'product_id' => $product->id,
                'quantity' => 1,
            ])
            ->assertOk();

        $item = CartItem::query()->firstOrFail();

        $this->actingAs($user, 'sanctum')
            ->putJson("/api/cart/items/{$item->id}", [
                'quantity' => 3,
            ])
            ->assertOk()
            ->assertJsonPath('data.items.0.quantity', 3);
    }

    public function test_cart_rejects_update_quantity_above_stock(): void
    {
        [$user, $product] = $this->makeProductWithStock(2, 'CART-UPDATE-002');

        $this->actingAs($user, 'sanctum')
            ->postJson('/api/cart/items', [
                'product_id' => $product->id,
                'quantity' => 1,
            ])
            ->assertOk();

        $item = CartItem::query()->firstOrFail();

        $this->actingAs($user, 'sanctum')
            ->putJson("/api/cart/items/{$item->id}", [
                'quantity' => 3,
            ])
            ->assertStatus(422);
    }

    public function test_customer_can_delete_one_cart_item(): void
    {
        [$user, $product] = $this->makeProductWithStock(5, 'CART-DELETE-001');

        $this->actingAs($user, 'sanctum')
            ->postJson('/api/cart/items', [
                'product_id' => $product->id,
                'quantity' => 1,
            ])
            ->assertOk();

        $item = CartItem::query()->firstOrFail();

        $this->actingAs($user, 'sanctum')
            ->deleteJson("/api/cart/items/{$item->id}")
            ->assertOk()
            ->assertJsonPath('success', true);

        $this->assertDatabaseMissing('cart_items', ['id' => $item->id]);
    }

    public function test_customer_cannot_modify_another_customers_cart_item(): void
    {
        [$otherUser, $product] = $this->makeProductWithStock(5, 'CART-AUTH-001');
        $user = User::factory()->create();

        $this->actingAs($otherUser, 'sanctum')
            ->postJson('/api/cart/items', [
                'product_id' => $product->id,
                'quantity' => 1,
            ])
            ->assertOk();

        $item = CartItem::query()->firstOrFail();

        $this->actingAs($user, 'sanctum')
            ->putJson("/api/cart/items/{$item->id}", [
                'quantity' => 2,
            ])
            ->assertForbidden();
    }

    public function test_customer_can_create_address_and_first_address_becomes_default(): void
    {
        $user = User::factory()->create();

        $this->actingAs($user, 'sanctum')
            ->postJson('/api/addresses', [
                'title' => 'Home',
                'receiver_name' => 'Test Receiver',
                'receiver_phone' => '09120000000',
                'recipient_name' => 'Test User',
                'recipient_phone' => '09120000000',
                'province' => 'Yazd',
                'city' => 'Yazd',
                'address' => 'Test address',
                'postal_code' => '1111111111',
            ])
            ->assertCreated()
            ->assertJsonPath('data.is_default', true);
    }

    public function test_customer_can_change_default_address(): void
    {
        $user = User::factory()->create();
        $first = $this->makeAddress($user);
        $second = $this->makeAddress($user, false, 'Second address');

        $this->actingAs($user, 'sanctum')
            ->putJson("/api/addresses/{$second->id}", [
                'is_default' => true,
            ])
            ->assertOk();

        $this->assertDatabaseHas('addresses', ['id' => $first->id, 'is_default' => false]);
        $this->assertDatabaseHas('addresses', ['id' => $second->id, 'is_default' => true]);
    }

    public function test_customer_can_change_default_address_with_second_address(): void
    {
        $user = User::factory()->create();
        $first = $this->makeAddress($user);
        $second = $this->makeAddress($user, false, 'Second address');

        $this->actingAs($user, 'sanctum')
            ->postJson("/api/addresses/{$second->id}/default")
            ->assertOk();

        $this->assertDatabaseHas('addresses', ['id' => $first->id, 'is_default' => false]);
        $this->assertDatabaseHas('addresses', ['id' => $second->id, 'is_default' => true]);
    }

    public function test_deleting_default_address_selects_another_address(): void
    {
        $user = User::factory()->create();
        $first = $this->makeAddress($user);
        $second = $this->makeAddress($user, false, 'Second address');

        $this->actingAs($user, 'sanctum')
            ->deleteJson("/api/addresses/{$first->id}")
            ->assertOk();

        $this->assertDatabaseHas('addresses', ['id' => $second->id, 'is_default' => true]);
    }

    public function test_customer_cannot_view_another_customers_address(): void
    {
        $user = User::factory()->create();
        $otherUser = User::factory()->create();
        $address = $this->makeAddress($otherUser);

        $this->actingAs($user, 'sanctum')
            ->getJson("/api/addresses/{$address->id}")
            ->assertForbidden();
    }

    public function test_customer_cannot_update_another_customers_address(): void
    {
        $user = User::factory()->create();
        $otherUser = User::factory()->create();
        $address = $this->makeAddress($otherUser);

        $this->actingAs($user, 'sanctum')
            ->putJson("/api/addresses/{$address->id}", [
                'title' => 'Not mine',
            ])
            ->assertForbidden();
    }

    public function test_checkout_calculates_normal_price_and_shipping(): void
    {
        [$user, $product] = $this->makeProductWithStock(5, 'CHECKOUT-001');
        Setting::updateOrCreate(
            ['key' => 'shipping_price'],
            [
                'value' => '20',
                'type' => 'number',
            ]
        );
        Setting::updateOrCreate(
            ['key' => 'free_shipping_threshold'],
            [
                'value' => '1000',
                'type' => 'number',
            ]
        );

        $this->actingAs($user, 'sanctum')
            ->postJson('/api/cart/items', [
                'product_id' => $product->id,
                'quantity' => 2,
            ])
            ->assertOk();

        $response = $this->actingAs($user, 'sanctum')
            ->postJson('/api/checkout/calculate');

        $response
            ->assertOk()
            ->assertJsonPath('success', true)
            ->assertJsonPath('data.subtotal', 200)
            ->assertJsonPath('data.discount', 0)
            ->assertJsonPath('data.shipping', 20)
            ->assertJsonPath('data.total', 220);
    }

    public function test_checkout_applies_free_shipping_at_threshold(): void
    {
        [$user, $product] = $this->makeProductWithStock(5, 'CHECKOUT-002');
        Setting::updateOrCreate(
            ['key' => 'shipping_price'],
            [
                'value' => '20',
                'type' => 'number',
            ]
        );
        Setting::updateOrCreate(
            ['key' => 'free_shipping_threshold'],
            [
                'value' => '200',
                'type' => 'number',
            ]
        );

        $this->actingAs($user, 'sanctum')
            ->postJson('/api/cart/items', [
                'product_id' => $product->id,
                'quantity' => 2,
            ])
            ->assertOk();

        $response = $this->actingAs($user, 'sanctum')
            ->postJson('/api/checkout/calculate');

        $response
            ->assertOk()
            ->assertJsonPath('data.subtotal', 200)
            ->assertJsonPath('data.discount', 0)
            ->assertJsonPath('data.shipping', 0)
            ->assertJsonPath('data.total', 200);
    }

    public function test_checkout_applies_percentage_coupon(): void
    {
        [$user, $product] = $this->makeProductWithStock(5, 'CHECKOUT-003');
        Setting::updateOrCreate(
            ['key' => 'shipping_price'],
            [
                'value' => '20',
                'type' => 'number',
            ]
        );
        Setting::updateOrCreate(
            ['key' => 'free_shipping_threshold'],
            [
                'value' => '1000',
                'type' => 'number',
            ]
        );

        Coupon::create([
            'code' => 'SAVE10',
            'type' => 'percentage',
            'value' => 10,
            'minimum_order_amount' => 0,
            'maximum_discount' => null,
            'starts_at' => null,
            'ends_at' => null,
            'usage_limit' => null,
            'per_user_limit' => null,
            'is_active' => true,
        ]);

        $this->actingAs($user, 'sanctum')
            ->postJson('/api/cart/items', [
                'product_id' => $product->id,
                'quantity' => 2,
            ])
            ->assertOk();

        $response = $this->actingAs($user, 'sanctum')
            ->postJson('/api/checkout/calculate', [
                'coupon_code' => 'save10',
            ]);

        $response
            ->assertOk()
            ->assertJsonPath('success', true)
            ->assertJsonPath('data.subtotal', 200)
            ->assertJsonPath('data.discount', 20)
            ->assertJsonPath('data.shipping', 20)
            ->assertJsonPath('data.total', 200)
            ->assertJsonPath('data.coupon.code', 'SAVE10');
    }

    public function test_checkout_rejects_empty_cart(): void
    {
        $user = User::factory()->create();

        $this->actingAs($user, 'sanctum')
            ->postJson('/api/checkout/calculate')
            ->assertStatus(400)
            ->assertJsonPath('success', false)
            ->assertJsonPath('message', 'Cart is empty');
    }

    public function test_checkout_rejects_invalid_coupon(): void
    {
        [$user, $product] = $this->makeProductWithStock(5, 'CHECKOUT-004');

        $this->actingAs($user, 'sanctum')
            ->postJson('/api/cart/items', [
                'product_id' => $product->id,
                'quantity' => 1,
            ])
            ->assertOk();

        $response = $this->actingAs($user, 'sanctum')
            ->postJson('/api/checkout/calculate', [
                'coupon_code' => 'NOT-EXIST',
            ]);

        $response
            ->assertStatus(422)
            ->assertJsonPath('success', false)
            ->assertJsonStructure([
                'errors' => ['code'],
            ]);
    }

    public function test_checkout_respects_coupon_maximum_discount(): void
    {
        [$user, $product] = $this->makeProductWithStock(10, 'CHECKOUT-005');
        Setting::updateOrCreate(
            ['key' => 'shipping_price'],
            [
                'value' => '20',
                'type' => 'number',
            ]
        );
        Setting::updateOrCreate(
            ['key' => 'free_shipping_threshold'],
            [
                'value' => '1000',
                'type' => 'number',
            ]
        );

        Coupon::create([
            'code' => 'CAP20',
            'type' => 'percentage',
            'value' => 50,
            'minimum_order_amount' => 0,
            'maximum_discount' => 20,
            'starts_at' => null,
            'ends_at' => null,
            'usage_limit' => null,
            'per_user_limit' => null,
            'is_active' => true,
        ]);

        $this->actingAs($user, 'sanctum')
            ->postJson('/api/cart/items', [
                'product_id' => $product->id,
                'quantity' => 2,
            ])
            ->assertOk();

        $response = $this->actingAs($user, 'sanctum')
            ->postJson('/api/checkout/calculate', [
                'coupon_code' => 'CAP20',
            ]);

        $response
            ->assertOk()
            ->assertJsonPath('data.subtotal', 200)
            ->assertJsonPath('data.discount', 20)
            ->assertJsonPath('data.shipping', 20)
            ->assertJsonPath('data.total', 200);
    }

    public function withToken(string $token, string $type = 'Bearer'): self
    {
        return $this->withHeader('Authorization', "Bearer {$token}");
    }

    private function makeProductWithStock(int $stock, string $sku): array
    {
        $user = User::factory()->create();
        $category = Category::create([
            'name' => 'Test category',
            'slug' => 'test-category-' . uniqid(),
            'is_active' => true,
        ]);
        $product = Product::create([
            'category_id' => $category->id,
            'name' => 'Test product',
            'slug' => 'test-product-' . uniqid(),
            'sku' => $sku,
            'price' => 100,
            'stock' => $stock,
            'status' => 'active',
        ]);

        return [$user, $product];
    }

    private function makeAddress(User $user, bool $isDefault = true, string $addressText = 'Test address'): Address
    {
        return Address::create([
            'user_id' => $user->id,
            'title' => 'Home',
            'receiver_name' => 'Test Receiver',
            'receiver_phone' => '09120000000',
            'recipient_name' => 'Test User',
            'recipient_phone' => '09120000000',
            'province' => 'Yazd',
            'city' => 'Yazd',
            'address' => $addressText,
            'postal_code' => '1111111111',
            'is_default' => $isDefault,
        ]);
    }

    private function makeOrder(User $user, Address $address)
    {
        [$orderUser, $product] = $this->makeProductWithStock(5, 'ORDER-AUTH-' . uniqid());
        $orderUser->update(['id' => $user->id]);
        $address->update(['user_id' => $user->id]);

        $this->actingAs($user, 'sanctum')
            ->postJson('/api/cart/items', [
                'product_id' => $product->id,
                'quantity' => 1,
            ])
            ->assertOk();

        $response = $this->actingAs($user, 'sanctum')
            ->postJson('/api/orders', ['address_id' => $address->id]);

        $response->assertCreated();

        return \App\Models\Order::findOrFail($response->json('data.id'));
    }
}
