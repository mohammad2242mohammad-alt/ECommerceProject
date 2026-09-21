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


    public function test_registration_rejects_a_password_shorter_than_six_characters(): void
    {
        $response = $this->postJson('/api/auth/register', [
            'phone' => '09123334456',
            'password' => '12345',
            'password_confirmation' => '12345',
        ]);

        $response
            ->assertStatus(422)
            ->assertJsonPath('success', false)
            ->assertJsonStructure(['success', 'message', 'errors']);
    }

    public function test_registration_rejects_mismatched_password_confirmation(): void
    {
        $response = $this->postJson('/api/auth/register', [
            'phone' => '09123334457',
            'password' => 'secret123',
            'password_confirmation' => 'different123',
        ]);

        $response
            ->assertStatus(422)
            ->assertJsonPath('success', false)
            ->assertJsonPath('errors.password.0', fn ($value) => is_string($value));
    }

    public function test_registration_rejects_duplicate_phone(): void
    {
        User::factory()->create([
            'phone' => '09123334458',
        ]);

        $response = $this->postJson('/api/auth/register', [
            'phone' => '09123334458',
            'password' => 'secret123',
            'password_confirmation' => 'secret123',
        ]);

        $response
            ->assertStatus(422)
            ->assertJsonPath('success', false)
            ->assertJsonPath('errors.phone.0', fn ($value) => is_string($value));
    }

    public function test_login_matches_the_api_contract(): void
    {
        User::factory()->create([
            'phone' => '09123334459',
            'password' => 'password',
            'is_active' => true,
        ]);

        $response = $this->postJson('/api/auth/login', [
            'phone' => '09123334459',
            'password' => 'password',
        ]);

        $response
            ->assertOk()
            ->assertJsonPath('success', true)
            ->assertJsonStructure([
                'success',
                'message',
                'data' => ['user', 'token'],
            ])
            ->assertJsonMissingPath('data.user.password');
    }

    public function test_login_rejects_invalid_credentials(): void
    {
        User::factory()->create([
            'phone' => '09123334460',
            'password' => 'password',
        ]);

        $this->postJson('/api/auth/login', [
            'phone' => '09123334460',
            'password' => 'wrong-password',
        ])
            ->assertStatus(401)
            ->assertJsonPath('success', false)
            ->assertJsonPath('message', 'Invalid phone or password');
    }

    public function test_login_rejects_inactive_user(): void
    {
        User::factory()->create([
            'phone' => '09123334461',
            'password' => 'password',
            'is_active' => false,
        ]);

        $this->postJson('/api/auth/login', [
            'phone' => '09123334461',
            'password' => 'password',
        ])
            ->assertStatus(403)
            ->assertJsonPath('success', false)
            ->assertJsonPath('message', 'User account is inactive');
    }

    public function test_authenticated_user_can_read_me(): void
    {
        $user = User::factory()->create();

        $this->actingAs($user, 'sanctum')
            ->getJson('/api/auth/me')
            ->assertOk()
            ->assertJsonPath('success', true)
            ->assertJsonStructure([
                'success',
                'message',
                'data' => ['user'],
            ])
            ->assertJsonMissingPath('data.user.password');
    }

    public function test_me_requires_authentication(): void
    {
        $this->getJson('/api/auth/me')
            ->assertUnauthorized();
    }

    public function test_logout_revokes_the_current_token(): void
    {
        $user = User::factory()->create();

        $token = $user->createToken('auth_token')->plainTextToken;

        $this->withToken($token)
            ->postJson('/api/auth/logout')
            ->assertOk()
            ->assertJsonPath('success', true)
            ->assertJsonPath('data', null);

        $this->withToken($token)
            ->getJson('/api/auth/me')
            ->assertUnauthorized();
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
