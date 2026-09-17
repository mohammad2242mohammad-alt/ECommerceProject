<?php

namespace Tests\Feature;

use App\Models\Category;
use App\Models\Product;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class FavoriteContractTest extends TestCase
{
    use RefreshDatabase;

    public function test_customer_can_add_favorite(): void
    {
        [$user, $product] = $this->makeProductWithStock(5, 'FAV-001-' . uniqid());

        $response = $this->actingAs($user, 'sanctum')
            ->postJson('/api/favorites', [
                'product_id' => $product->id,
            ]);

        $response
            ->assertCreated()
            ->assertJsonPath('success', true)
            ->assertJsonPath('data.product_id', $product->id);

        $this->assertDatabaseHas('favorites', [
            'user_id' => $user->id,
            'product_id' => $product->id,
        ]);
    }

    public function test_duplicate_favorite_does_not_create_duplicate(): void
    {
        [$user, $product] = $this->makeProductWithStock(5, 'FAV-002-' . uniqid());

        $this->actingAs($user, 'sanctum')
            ->postJson('/api/favorites', [
                'product_id' => $product->id,
            ])
            ->assertCreated();

        $this->actingAs($user, 'sanctum')
            ->postJson('/api/favorites', [
                'product_id' => $product->id,
            ])
            ->assertCreated();

        $this->assertDatabaseCount('favorites', 1);
    }

    public function test_customer_can_list_only_own_favorites(): void
    {
        [$user, $product] = $this->makeProductWithStock(5, 'FAV-003-' . uniqid());
        [$otherUser, $otherProduct] = $this->makeProductWithStock(5, 'FAV-004-' . uniqid());

        $this->actingAs($user, 'sanctum')
            ->postJson('/api/favorites', [
                'product_id' => $product->id,
            ])
            ->assertCreated();

        $this->actingAs($otherUser, 'sanctum')
            ->postJson('/api/favorites', [
                'product_id' => $otherProduct->id,
            ])
            ->assertCreated();

        $response = $this->actingAs($user, 'sanctum')
            ->getJson('/api/favorites');

        $response
            ->assertOk()
            ->assertJsonPath('success', true)
            ->assertJsonCount(1, 'data.data')
            ->assertJsonPath('data.data.0.product_id', $product->id);
    }

    public function test_customer_can_remove_favorite(): void
    {
        [$user, $product] = $this->makeProductWithStock(5, 'FAV-005-' . uniqid());

        $this->actingAs($user, 'sanctum')
            ->postJson('/api/favorites', [
                'product_id' => $product->id,
            ])
            ->assertCreated();

        $response = $this->actingAs($user, 'sanctum')
            ->deleteJson("/api/favorites/{$product->id}");

        $response
            ->assertOk()
            ->assertJsonPath('success', true)
            ->assertJsonPath('data', null);

        $this->assertDatabaseMissing('favorites', [
            'user_id' => $user->id,
            'product_id' => $product->id,
        ]);
    }

    public function test_customer_cannot_remove_another_customers_favorite(): void
    {
        [$user, $product] = $this->makeProductWithStock(5, 'FAV-006-' . uniqid());
        $otherUser = User::factory()->create();

        $this->actingAs($otherUser, 'sanctum')
            ->postJson('/api/favorites', [
                'product_id' => $product->id,
            ])
            ->assertCreated();

        $response = $this->actingAs($user, 'sanctum')
            ->deleteJson("/api/favorites/{$product->id}");

        $response
            ->assertNotFound()
            ->assertJsonPath('success', false);

        $this->assertDatabaseHas('favorites', [
            'user_id' => $otherUser->id,
            'product_id' => $product->id,
        ]);
    }

    public function test_customer_cannot_add_favorite_for_nonexistent_product(): void
    {
        [$user] = $this->makeProductWithStock(5, 'FAV-007-' . uniqid());

        $response = $this->actingAs($user, 'sanctum')
            ->postJson('/api/favorites', [
                'product_id' => 999999999,
            ]);

        $response->assertUnprocessable();
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
}
