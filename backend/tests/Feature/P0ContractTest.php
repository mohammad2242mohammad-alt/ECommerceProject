<?php

namespace Tests\Feature;

use App\Models\Address;
use App\Models\CartItem;
use App\Models\Order;
use App\Models\Product;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class P0ContractTest extends TestCase
{
    use RefreshDatabase;

    protected function setUp(): void
    {
        parent::setUp();

        $this->seed();
    }

    public function test_authentication_lifecycle_and_unauthenticated_access(): void
    {
        $register = $this->postJson('/api/auth/register', [
            'name' => 'P0 User',
            'phone' => '09123334455',
            'password' => 'password',
            'password_confirmation' => 'password',
        ]);

        $register->assertCreated()
            ->assertJsonPath('success', true)
            ->assertJsonStructure(['data' => ['user', 'token']]);

        $token = $register->json('data.token');

        $this->withToken($token)
            ->getJson('/api/auth/me')
            ->assertOk()
            ->assertJsonPath('success', true);

        $this->withToken($token)
            ->postJson('/api/auth/logout')
            ->assertOk()
            ->assertJsonPath('success', true);

        $this->withToken($token)
            ->getJson('/api/auth/me')
            ->assertStatus(401);

        $this->getJson('/api/cart')->assertStatus(401);

        $this->postJson('/api/auth/login', [
            'phone' => '09120000002',
            'password' => 'password',
        ])->assertOk()
            ->assertJsonPath('success', true)
            ->assertJsonStructure(['data' => ['user', 'token']]);
    }

    public function test_catalog_endpoints_return_current_contract_shape(): void
    {
        $this->getJson('/api/home')
            ->assertOk()
            ->assertJsonPath('success', true)
            ->assertJsonStructure(['data' => ['banners', 'categories', 'products']]);

        $this->getJson('/api/categories')
            ->assertOk()
            ->assertJsonPath('success', true);

        $product = Product::where('status', 'active')->firstOrFail();

        $this->getJson('/api/products')
            ->assertOk()
            ->assertJsonPath('success', true)
            ->assertJsonStructure(['data']);

        $this->getJson('/api/products/'.$product->id)
            ->assertOk()
            ->assertJsonPath('success', true)
            ->assertJsonPath('data.id', $product->id);
    }

    public function test_cart_enforces_stock_and_uses_server_side_discounted_price(): void
    {
        $user = User::where('phone', '09120000002')->firstOrFail();
        $product = Product::where('slug', 'samsung-galaxy-a55')->firstOrFail();

        $this->actingAs($user, 'sanctum')
            ->postJson('/api/cart/items', [
                'product_id' => $product->id,
                'quantity' => 1,
            ])
            ->assertOk()
            ->assertJsonPath('success', true);

        $item = CartItem::whereHas('cart', fn ($q) => $q->where('user_id', $user->id))
            ->where('product_id', $product->id)
            ->firstOrFail();

        $this->assertSame(16500000.0, (float) $item->price);

        $this->actingAs($user, 'sanctum')
            ->postJson('/api/cart/items', [
                'product_id' => $product->id,
                'quantity' => $product->stock + 1,
            ])
            ->assertStatus(422)
            ->assertJsonStructure(['errors']);
    }

    public function test_addresses_are_owned_by_the_authenticated_user(): void
    {
        $owner = User::factory()->create();
        $other = User::factory()->create();

        $payload = [
            'title' => 'خانه',
            'receiver_name' => 'P0 User',
            'receiver_phone' => '09121112233',
            'province' => 'Yazd',
            'city' => 'Yazd',
            'address' => 'Test address',
            'postal_code' => '8910000000',
            'is_default' => true,
        ];

        $created = $this->actingAs($owner, 'sanctum')
            ->postJson('/api/addresses', $payload)
            ->assertCreated()
            ->assertJsonPath('data.is_default', true);

        $addressId = $created->json('data.id');

        $this->actingAs($other, 'sanctum')
            ->getJson('/api/addresses/'.$addressId)
            ->assertNotFound();
    }

    public function test_checkout_calculates_totals_on_the_server(): void
    {
        $user = User::where('phone', '09120000002')->firstOrFail();
        $product = Product::where('slug', 'samsung-galaxy-a55')->firstOrFail();

        $this->actingAs($user, 'sanctum')
            ->postJson('/api/cart/items', [
                'product_id' => $product->id,
                'quantity' => 2,
            ])->assertOk();

        $response = $this->actingAs($user, 'sanctum')
            ->postJson('/api/checkout/calculate')
            ->assertOk()
            ->assertJsonPath('success', true)
            ->assertJsonStructure(['data' => ['subtotal', 'discount', 'shipping', 'total']]);

        $this->assertSame(33000000.0, (float) $response->json('data.subtotal'));
        $this->assertSame(33000000.0, (float) $response->json('data.total'));
    }

    public function test_order_creation_snapshots_price_decrements_stock_and_cancellation_restores_it(): void
    {
        $user = User::where('phone', '09120000002')->firstOrFail();
        $product = Product::where('slug', 'samsung-galaxy-a55')->firstOrFail();
        $address = Address::create([
            'user_id' => $user->id,
            'title' => 'خانه',
            'receiver_name' => 'کاربر آزمایشی',
            'receiver_phone' => $user->phone,
            'province' => 'Yazd',
            'city' => 'Yazd',
            'address' => 'Test address',
            'postal_code' => '8910000000',
            'is_default' => true,
        ]);

        $this->actingAs($user, 'sanctum')
            ->postJson('/api/cart/items', [
                'product_id' => $product->id,
                'quantity' => 2,
            ])->assertOk();

        $orderResponse = $this->actingAs($user, 'sanctum')
            ->postJson('/api/orders', [
                'address_id' => $address->id,
            ])
            ->assertCreated()
            ->assertJsonPath('success', true);

        $orderId = $orderResponse->json('data.id');
        $this->assertNotNull($orderId);

        $this->assertSame(23, (int) $product->fresh()->stock);

        $order = Order::findOrFail($orderId);
        $this->assertSame('pending', $order->order_status);
        $this->assertCount(1, $order->items);
        $this->assertSame(16500000.0, (float) $order->items->first()->unit_price);

        $this->actingAs($user, 'sanctum')
            ->postJson('/api/orders/'.$orderId.'/cancel')
            ->assertOk()
            ->assertJsonPath('success', true);

        $this->assertSame(25, (int) $product->fresh()->stock);
    }

    public function test_orders_and_payments_are_not_cross_user_accessible(): void
    {
        $owner = User::where('phone', '09120000002')->firstOrFail();
        $other = User::factory()->create();
        $product = Product::where('slug', 'samsung-galaxy-a55')->firstOrFail();

        $address = Address::create([
            'user_id' => $owner->id,
            'title' => 'خانه',
            'receiver_name' => 'کاربر آزمایشی',
            'receiver_phone' => $owner->phone,
            'province' => 'Yazd',
            'city' => 'Yazd',
            'address' => 'Test address',
            'postal_code' => '8910000000',
            'is_default' => true,
        ]);

        $this->actingAs($owner, 'sanctum')
            ->postJson('/api/cart/items', [
                'product_id' => $product->id,
                'quantity' => 1,
            ])->assertOk();

        $order = $this->actingAs($owner, 'sanctum')
            ->postJson('/api/orders', ['address_id' => $address->id])
            ->assertCreated()
            ->json('data');

        $this->actingAs($other, 'sanctum')
            ->getJson('/api/orders/'.$order['id'])
            ->assertNotFound();

        $this->actingAs($other, 'sanctum')
            ->postJson('/api/payments/'.$order['id'].'/start', ['simulate' => 'success'])
            ->assertNotFound();
    }

    public function test_payment_success_updates_order_and_second_payment_is_rejected(): void
    {
        $user = User::where('phone', '09120000002')->firstOrFail();
        $product = Product::where('slug', 'wireless-headphone')->firstOrFail();

        $address = Address::create([
            'user_id' => $user->id,
            'title' => 'خانه',
            'receiver_name' => 'کاربر آزمایشی',
            'receiver_phone' => $user->phone,
            'province' => 'Yazd',
            'city' => 'Yazd',
            'address' => 'Test address',
            'postal_code' => '8910000000',
            'is_default' => true,
        ]);

        $this->actingAs($user, 'sanctum')
            ->postJson('/api/cart/items', [
                'product_id' => $product->id,
                'quantity' => 1,
            ])->assertOk();

        $order = $this->actingAs($user, 'sanctum')
            ->postJson('/api/orders', ['address_id' => $address->id])
            ->assertCreated()
            ->json('data');

        $orderId = $order['id'];

        $this->actingAs($user, 'sanctum')
            ->postJson('/api/payments/'.$orderId.'/start', ['simulate' => 'success'])
            ->assertOk()
            ->assertJsonPath('data.order.payment_status', 'paid');

        $this->actingAs($user, 'sanctum')
            ->postJson('/api/payments/'.$orderId.'/start', ['simulate' => 'success'])
            ->assertStatus(422);
    }
}
