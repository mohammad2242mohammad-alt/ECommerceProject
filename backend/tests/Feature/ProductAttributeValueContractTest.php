<?php

namespace Tests\Feature;

use App\Models\Category;
use App\Models\CategoryAttribute;
use App\Models\Product;
use App\Models\ProductAttributeValue;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class ProductAttributeValueContractTest extends TestCase
{
    use RefreshDatabase;

    private function makeProductAndAttribute(): array
    {
        $category = Category::create([
            'name' => 'Product attribute category',
            'slug' => 'product-attribute-category-' . uniqid(),
            'is_active' => true,
        ]);

        $product = Product::create([
            'category_id' => $category->id,
            'name' => 'Attribute product',
            'slug' => 'attribute-product-' . uniqid(),
            'sku' => 'ATTR-' . uniqid(),
            'price' => 1000,
            'stock' => 10,
            'status' => 'active',
        ]);

        $attribute = CategoryAttribute::create([
            'category_id' => $category->id,
            'name' => 'Color',
            'slug' => 'color-' . uniqid(),
            'type' => 'text',
            'is_required' => false,
            'sort_order' => 0,
        ]);

        return [$product, $attribute];
    }

    public function test_public_product_attribute_values_include_attribute(): void
    {
        [$product, $attribute] = $this->makeProductAndAttribute();

        ProductAttributeValue::create([
            'product_id' => $product->id,
            'category_attribute_id' => $attribute->id,
            'value' => 'Black',
        ]);

        $this->getJson("/api/products/{$product->id}/attributes")
            ->assertOk()
            ->assertJsonPath('success', true)
            ->assertJsonPath('data.0.value', 'Black')
            ->assertJsonPath('data.0.attribute.id', $attribute->id);
    }

    public function test_admin_can_create_update_and_delete_product_attribute_value(): void
    {
        $admin = User::factory()->create(['role' => 'admin']);
        [$product, $attribute] = $this->makeProductAndAttribute();

        $create = $this->actingAs($admin, 'sanctum')
            ->postJson("/api/products/{$product->id}/attributes", [
                'category_attribute_id' => $attribute->id,
                'value' => 'White',
            ])
            ->assertCreated()
            ->assertJsonPath('success', true);

        $valueId = $create->json('data.id');

        $this->actingAs($admin, 'sanctum')
            ->putJson("/api/product-attribute-values/{$valueId}", [
                'value' => 'Blue',
            ])
            ->assertOk()
            ->assertJsonPath('data.value', 'Blue');

        $this->actingAs($admin, 'sanctum')
            ->deleteJson("/api/product-attribute-values/{$valueId}")
            ->assertOk()
            ->assertJsonPath('success', true);

        $this->assertDatabaseMissing('product_attribute_values', ['id' => $valueId]);
    }

    public function test_product_attribute_value_requires_existing_attribute(): void
    {
        $admin = User::factory()->create(['role' => 'admin']);
        [$product] = $this->makeProductAndAttribute();

        $this->actingAs($admin, 'sanctum')
            ->postJson("/api/products/{$product->id}/attributes", [
                'category_attribute_id' => 999999,
                'value' => 'Invalid',
            ])
            ->assertStatus(422);
    }
}
