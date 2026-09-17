<?php

namespace Tests\Feature;

use App\Models\Category;
use App\Models\Product;
use App\Models\ProductVariant;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class ProductVariantContractTest extends TestCase
{
    use RefreshDatabase;

    private function makeProduct(): Product
    {
        $category = Category::create([
            'name' => 'Variant category',
            'slug' => 'variant-category-' . uniqid(),
            'is_active' => true,
        ]);

        return Product::create([
            'category_id' => $category->id,
            'name' => 'Variant product',
            'slug' => 'variant-product-' . uniqid(),
            'sku' => 'VARIANT-' . uniqid(),
            'price' => 1000,
            'stock' => 10,
            'status' => 'active',
        ]);
    }

    public function test_public_variant_list_returns_only_active_variants_for_active_product(): void
    {
        $product = $this->makeProduct();
        ProductVariant::create([
            'product_id' => $product->id,
            'sku' => 'ACTIVE-' . uniqid(),
            'price' => 1200,
            'stock' => 5,
            'is_active' => true,
            'status' => 'active',
        ]);
        ProductVariant::create([
            'product_id' => $product->id,
            'sku' => 'INACTIVE-' . uniqid(),
            'price' => 1300,
            'stock' => 5,
            'is_active' => false,
            'status' => 'inactive',
        ]);

        $response = $this->getJson("/api/products/{$product->id}/variants")
            ->assertOk()
            ->assertJsonPath('success', true);

        $data = $response->json('data');
        $this->assertCount(1, $data);
        $this->assertSame('active', $data[0]['status']);
    }

    public function test_admin_can_create_update_and_delete_a_variant(): void
    {
        $admin = User::factory()->create(['is_admin' => true]);
        $product = $this->makeProduct();

        $create = $this->actingAs($admin, 'sanctum')
            ->postJson("/api/products/{$product->id}/variants", [
                'sku' => 'ADMIN-VARIANT',
                'price' => 1500,
                'discount_price' => 1400,
                'stock' => 7,
                'status' => 'active',
            ])
            ->assertCreated()
            ->assertJsonPath('success', true);

        $variantId = $create->json('data.id');

        $this->actingAs($admin, 'sanctum')
            ->putJson("/api/variants/{$variantId}", [
                'price' => 1600,
                'status' => 'inactive',
            ])
            ->assertOk()
            ->assertJsonPath('data.price', '1600.00')
            ->assertJsonPath('data.status', 'inactive');

        $this->actingAs($admin, 'sanctum')
            ->deleteJson("/api/variants/{$variantId}")
            ->assertOk()
            ->assertJsonPath('success', true);

        $this->assertDatabaseMissing('product_variants', ['id' => $variantId]);
    }

    public function test_variant_with_cart_reference_cannot_be_deleted(): void
    {
        $admin = User::factory()->create(['is_admin' => true]);
        $product = $this->makeProduct();
        $variant = ProductVariant::create([
            'product_id' => $product->id,
            'sku' => 'REFERENCED-' . uniqid(),
            'price' => 1500,
            'stock' => 5,
            'is_active' => true,
            'status' => 'active',
        ]);

        \DB::table('cart_items')->insert([
            'cart_id' => \DB::table('carts')->insertGetId(['user_id' => $admin->id]),
            'product_id' => $product->id,
            'variant_id' => $variant->id,
            'quantity' => 1,
            'price' => 1500,
        ]);

        $this->actingAs($admin, 'sanctum')
            ->deleteJson("/api/variants/{$variant->id}")
            ->assertStatus(422)
            ->assertJsonPath('success', false);

        $this->assertDatabaseHas('product_variants', ['id' => $variant->id]);
    }
}
