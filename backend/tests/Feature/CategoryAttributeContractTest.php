<?php

namespace Tests\Feature;

use App\Models\Category;
use App\Models\CategoryAttribute;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class CategoryAttributeContractTest extends TestCase
{
    use RefreshDatabase;

    private function makeCategory(): Category
    {
        return Category::create([
            'name' => 'Attribute category',
            'slug' => 'attribute-category-' . uniqid(),
            'is_active' => true,
        ]);
    }

    public function test_public_category_attributes_are_returned_in_sort_order(): void
    {
        $category = $this->makeCategory();

        CategoryAttribute::create([
            'category_id' => $category->id,
            'name' => 'Brand',
            'slug' => 'brand',
            'type' => 'text',
            'is_required' => false,
            'sort_order' => 2,
        ]);
        CategoryAttribute::create([
            'category_id' => $category->id,
            'name' => 'Color',
            'slug' => 'color',
            'type' => 'text',
            'is_required' => true,
            'sort_order' => 1,
        ]);

        $response = $this->getJson("/api/categories/{$category->id}/attributes")
            ->assertOk()
            ->assertJsonPath('success', true);

        $this->assertSame('Color', $response->json('data.0.name'));
        $this->assertSame('Brand', $response->json('data.1.name'));
    }

    public function test_admin_can_create_update_and_delete_category_attribute(): void
    {
        $admin = User::factory()->create(['role' => 'admin']);
        $category = $this->makeCategory();

        $create = $this->actingAs($admin, 'sanctum')
            ->postJson("/api/categories/{$category->id}/attributes", [
                'name' => 'Material',
                'slug' => 'material',
                'type' => 'text',
                'is_required' => true,
                'sort_order' => 1,
            ])
            ->assertCreated()
            ->assertJsonPath('success', true);

        $attributeId = $create->json('data.id');

        $this->actingAs($admin, 'sanctum')
            ->putJson("/api/attributes/{$attributeId}", [
                'name' => 'Updated Material',
                'sort_order' => 3,
            ])
            ->assertOk()
            ->assertJsonPath('data.name', 'Updated Material')
            ->assertJsonPath('data.sort_order', 3);

        $this->actingAs($admin, 'sanctum')
            ->deleteJson("/api/attributes/{$attributeId}")
            ->assertOk()
            ->assertJsonPath('success', true);

        $this->assertDatabaseMissing('category_attributes', ['id' => $attributeId]);
    }

    public function test_customer_cannot_manage_category_attributes(): void
    {
        $customer = User::factory()->create(['role' => 'customer']);
        $category = $this->makeCategory();

        $this->actingAs($customer, 'sanctum')
            ->postJson("/api/categories/{$category->id}/attributes", [
                'name' => 'Blocked',
                'slug' => 'blocked',
            ])
            ->assertStatus(403);
    }
}
