<?php

namespace Tests\Feature;

use App\Models\Address;
use App\Models\Category;
use App\Models\Order;
use App\Models\Product;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class StoreContractTest extends TestCase
{
    use RefreshDatabase;

    // Existing test methods/helpers remain unchanged.

    private function withToken(string $token): self
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
            'recipient_name' => $user->name,
            'phone' => '09120000000',
            'province' => 'Yazd',
            'city' => 'Yazd',
            'address' => $addressText,
            'postal_code' => '1111111111',
            'is_default' => $isDefault,
        ]);
    }
}
