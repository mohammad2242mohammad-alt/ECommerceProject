<?php

namespace Tests\Feature;

use App\Models\Product;
use App\Models\Category;
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
}
