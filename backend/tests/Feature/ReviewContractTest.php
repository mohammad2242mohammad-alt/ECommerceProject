<?php

namespace Tests\Feature;

use App\Models\Product;
use App\Models\Review;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class ReviewContractTest extends TestCase
{
    use RefreshDatabase;

    public function test_customer_can_submit_review_after_delivered_order(): void
    {
        $user = User::factory()->create();
        $address = $this->makeAddress($user);
        $order = $this->makeOrder($user, $address);
        $order->update(['order_status' => 'delivered']);

        $productId = (int) \DB::table('order_items')
            ->where('order_id', $order->id)
            ->value('product_id');

        $response = $this->actingAs($user, 'sanctum')
            ->postJson("/api/products/{$productId}/reviews", [
                'rating' => 5,
                'title' => 'Excellent',
                'body' => 'Very good product.',
            ]);

        $response
            ->assertCreated()
            ->assertJsonPath('success', true)
            ->assertJsonPath('data.product_id', $productId)
            ->assertJsonPath('data.order_id', $order->id)
            ->assertJsonPath('data.rating', 5)
            ->assertJsonPath('data.status', 'pending');

        $this->assertDatabaseHas('reviews', [
            'user_id' => $user->id,
            'product_id' => $productId,
            'order_id' => $order->id,
            'rating' => 5,
            'status' => 'pending',
        ]);
    }

    public function test_customer_cannot_submit_review_before_delivered_order(): void
    {
        [$user, $product] = $this->makeProductWithStock(5, 'REVIEW-002-' . uniqid());

        $response = $this->actingAs($user, 'sanctum')
            ->postJson("/api/products/{$product->id}/reviews", [
                'rating' => 5,
                'body' => 'Not eligible yet.',
            ]);

        $response
            ->assertForbidden()
            ->assertJsonPath('success', false);

        $this->assertDatabaseMissing('reviews', [
            'user_id' => $user->id,
            'product_id' => $product->id,
        ]);
    }

    public function test_customer_cannot_submit_duplicate_review_for_same_product(): void
    {
        $user = User::factory()->create();
        $address = $this->makeAddress($user);
        $order = $this->makeOrder($user, $address);
        $order->update(['order_status' => 'delivered']);

        $productId = (int) \DB::table('order_items')
            ->where('order_id', $order->id)
            ->value('product_id');

        $this->actingAs($user, 'sanctum')
            ->postJson("/api/products/{$productId}/reviews", [
                'rating' => 4,
                'body' => 'First review.',
            ])
            ->assertCreated();

        $response = $this->actingAs($user, 'sanctum')
            ->postJson("/api/products/{$productId}/reviews", [
                'rating' => 5,
                'body' => 'Second review.',
            ]);

        $response
            ->assertUnprocessable()
            ->assertJsonPath('success', false);

        $this->assertDatabaseCount('reviews', 1);
    }

    public function test_review_validation_rejects_invalid_rating_and_empty_body(): void
    {
        [$user, $product] = $this->makeProductWithStock(5, 'REVIEW-004-' . uniqid());

        $response = $this->actingAs($user, 'sanctum')
            ->postJson("/api/products/{$product->id}/reviews", [
                'rating' => 6,
                'body' => '',
            ]);

        $response->assertUnprocessable();
        $response->assertJsonValidationErrors(['rating', 'body']);
    }

    public function test_public_review_list_returns_only_approved_reviews(): void
    {
        [$owner, $product] = $this->makeProductWithStock(5, 'REVIEW-005-' . uniqid());
        $otherUser = User::factory()->create();

        Review::create([
            'user_id' => $owner->id,
            'product_id' => $product->id,
            'order_id' => null,
            'rating' => 5,
            'title' => 'Approved',
            'body' => 'Visible review.',
            'status' => 'approved',
        ]);

        Review::create([
            'user_id' => $otherUser->id,
            'product_id' => $product->id,
            'order_id' => null,
            'rating' => 1,
            'title' => 'Pending',
            'body' => 'Hidden review.',
            'status' => 'pending',
        ]);

        $response = $this->getJson("/api/products/{$product->id}/reviews");

        $response
            ->assertOk()
            ->assertJsonPath('success', true)
            ->assertJsonCount(1, 'data.data')
            ->assertJsonPath('data.data.0.status', 'approved')
            ->assertJsonPath('data.data.0.body', 'Visible review.');
    }

    private function makeProductWithStock(int $stock, string $sku): array
    {
        $user = User::factory()->create();
        $category = \App\Models\Category::create([
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

    private function makeAddress(User $user, bool $isDefault = true, string $addressText = 'Test address')
    {
        return \App\Models\Address::create([
            'user_id' => $user->id,
            'title' => 'Home',
            'receiver_name' => 'Test Receiver',
            'receiver_phone' => '09120000000',
            'recipient_name' => 'Test User',
            'recipient_phone' => '09120000000',
            'province' => 'Yazd',
            'city' => 'Yazd',
            'address' => $addressText,
            'postal_code' => '1111111111',
            'is_default' => $isDefault,
        ]);
    }

    private function makeOrder(User $user, $address)
    {
        [$orderUser, $product] = $this->makeProductWithStock(5, 'REVIEW-ORDER-' . uniqid());
        $orderUser->update(['id' => $user->id]);
        $address->update(['user_id' => $user->id]);

        $this->actingAs($user, 'sanctum')
            ->postJson('/api/cart/items', [
                'product_id' => $product->id,
                'quantity' => 1,
            ])
            ->assertOk();

        $response = $this->actingAs($user, 'sanctum')
            ->postJson('/api/orders', ['address_id' => $address->id]);

        $response->assertCreated();

        return \App\Models\Order::findOrFail($response->json('data.id'));
    }
}
