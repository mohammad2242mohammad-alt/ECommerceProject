<?php

namespace Tests\Feature;

use App\Models\Address;
use App\Models\Category;
use App\Models\Product;
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
            ->assertJsonPath('data.id', $user->id);

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

    public function test_customer_cannot_view_another_customers_order(): void
    {
        [$owner, $product] = $this->makeProductWithStock(5, 'OWNER-001');
        $address = $this->makeAddress($owner);
        $otherUser = User::factory()->create();

        $this->actingAs($owner, 'sanctum')
            ->postJson('/api/cart/items', [
                'product_id' => $product->id,
                'quantity' => 1,
            ])
            ->assertOk();

        $orderResponse = $this->actingAs($owner, 'sanctum')
            ->postJson('/api/orders', ['address_id' => $address->id])
            ->assertCreated();

        $orderId = $orderResponse->json('data.id');

        $this->actingAs($otherUser, 'sanctum')
            ->getJson("/api/orders/{$orderId}")
            ->assertNotFound();
    }

    public function test_non_admin_cannot_access_admin_api(): void
    {
        $user = User::factory()->create([
            'role' => 'customer',
            'is_active' => true,
        ]);

        $this->actingAs($user, 'sanctum')
            ->postJson('/api/categories/1/attributes', [])
            ->assertStatus(403);
    }

    public function test_admin_can_open_the_banner_management_screen(): void
    {
        User::factory()->create([
            'phone' => '09120000001',
            'password' => 'password',
            'role' => 'admin',
            'is_active' => true,
        ]);

        $this->post('/admin/login', [
            'phone' => '09120000001',
            'password' => 'password',
        ])->assertRedirect('/admin');

        $this->get('/admin/banners')->assertOk();
    }

    private function makeProductWithStock(int $stock, string $sku): array
    {
        $category = Category::create([
            'name' => "Category {$sku}",
            'slug' => strtolower($sku) . '-category',
            'is_active' => true,
        ]);

        $user = User::factory()->create();
        $product = Product::create([
            'category_id' => $category->id,
            'name' => "Product {$sku}",
            'slug' => strtolower($sku) . '-product',
            'sku' => $sku,
            'price' => 100,
            'stock' => $stock,
            'status' => 'active',
        ]);

        return [$user, $product];
    }

    private function makeAddress(User $user): Address
    {
        return Address::create([
            'user_id' => $user->id,
            'title' => 'Home',
            'receiver_name' => 'Test User',
            'receiver_phone' => '09123334455',
            'province' => 'Yazd',
            'city' => 'Yazd',
            'address' => 'Test address',
            'postal_code' => '1111111111',
            'is_default' => true,
        ]);
    }
}
