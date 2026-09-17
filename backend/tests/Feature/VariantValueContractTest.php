<?php

namespace Tests\Feature;

use App\Models\Category;
use App\Models\CategoryAttribute;
use App\Models\Product;
use App\Models\ProductVariant;
use App\Models\User;
use App\Models\VariantValue;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class VariantValueContractTest extends TestCase
{
    use RefreshDatabase;

    private function makeVariantAndAttribute(): array
    {
        $category = Category::create([
            'name' => 'Variant value category',
            'slug' => 'variant-value-category-' . uniqid(),
            'is_active' => true,
        ]);

        $product = Product::create([
            'category_id' => $category->id,
            'name' => 'Variant value product',
            'slug' => 'variant-value-product-' . uniqid(),
            'sku' => 'VV-' . uniqid(),
            'price' => 1000,
            'stock' => 10,
            'status' => 'active',
        ]);

        $variant = ProductVariant::create([
            'product_id' => $product->id,
            'sku' => 'VV-VARIANT-' . uniqid(),
            'price' => 1200,
            'stock' => 5,
            'is_active' => true,
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

        return [$variant, $attribute];
    }

    public function test_public_variant_values_include_attribute(): void
    {
        [$variant, $attribute] = $this->makeVariantAndAttribute();

        VariantValue::create([
            'product_variant_id' => $variant->id,
            'category_attribute_id' => $attribute->id,
            'value' => 'Red',
        ]);

        $this->getJson("/api/variants/{$variant->id}/values")
            ->assertOk()
            ->assertJsonPath('success', true)
            ->assertJsonPath('data.0.value', 'Red')
            ->assertJsonPath('data.0.attribute.id', $attribute->id);
    }

    public function test_admin_can_create_update_and_delete_variant_value(): void
    {
        $admin = User::factory()->create(['role' => 'admin']);
        [$variant, $attribute] = $this->makeVariantAndAttribute();

        $create = $this->actingAs($admin, 'sanctum')
            ->postJson("/api/variants/{$variant->id}/values", [
                'category_attribute_id' => $attribute->id,
                'value' => 'Large',
            ])
            ->assertCreated()
            ->assertJsonPath('success', true);

        $valueId = $create->json('data.id');

        $this->actingAs($admin, 'sanctum')
            ->putJson("/api/variant-values/{$valueId}", [
                'value' => 'XL',
            ])
            ->assertOk()
            ->assertJsonPath('data.value', 'XL');

        $this->actingAs($admin, 'sanctum')
            ->deleteJson("/api/variant-values/{$valueId}")
            ->assertOk()
            ->assertJsonPath('success', true);

        $this->assertDatabaseMissing('product_variant_values', ['id' => $valueId]);
    }

    public function test_variant_value_requires_existing_attribute(): void
    {
        $admin = User::factory()->create(['role' => 'admin']);
        [$variant] = $this->makeVariantAndAttribute();

        $this->actingAs($admin, 'sanctum')
            ->postJson("/api/variants/{$variant->id}/values", [
                'category_attribute_id' => 999999,
                'value' => 'Invalid',
            ])
            ->assertStatus(422);
    }
}
