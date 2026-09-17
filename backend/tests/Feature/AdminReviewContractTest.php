<?php

namespace Tests\Feature;

use App\Models\Category;
use App\Models\Product;
use App\Models\Review;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class AdminReviewContractTest extends TestCase
{
    use RefreshDatabase;

    private function makeReview(string $status = 'pending'): Review
    {
        $user = User::factory()->create();

        $category = Category::create([
            'name' => 'Review category',
            'slug' => 'review-category-' . uniqid(),
            'is_active' => true,
        ]);

        $product = Product::create([
            'category_id' => $category->id,
            'name' => 'Review product',
            'slug' => 'review-product-' . uniqid(),
            'sku' => 'REVIEW-' . uniqid(),
            'price' => 1000,
            'stock' => 10,
            'status' => 'active',
        ]);

        return Review::create([
            'user_id' => $user->id,
            'product_id' => $product->id,
            'order_id' => null,
            'rating' => 5,
            'title' => 'Test review',
            'body' => 'Test review body',
            'status' => $status,
        ]);
    }

    public function test_admin_can_approve_review(): void
    {
        $admin = User::factory()->create([
            'role' => 'admin',
            'is_active' => true,
        ]);

        $review = $this->makeReview();

        $response = $this->actingAs($admin)
            ->put('/admin/reviews/' . $review->id . '/status', [
                'status' => 'approved',
            ]);

        $response->assertRedirect();
        $this->assertDatabaseHas('reviews', [
            'id' => $review->id,
            'status' => 'approved',
        ]);
    }

    public function test_admin_review_status_rejects_invalid_status(): void
    {
        $admin = User::factory()->create([
            'role' => 'admin',
            'is_active' => true,
        ]);

        $review = $this->makeReview();

        $response = $this->actingAs($admin)
            ->from('/admin/reviews')
            ->put('/admin/reviews/' . $review->id . '/status', [
                'status' => 'published',
            ]);

        $response->assertSessionHasErrors('status');
        $this->assertDatabaseHas('reviews', [
            'id' => $review->id,
            'status' => 'pending',
        ]);
    }

    public function test_admin_can_delete_review(): void
    {
        $admin = User::factory()->create([
            'role' => 'admin',
            'is_active' => true,
        ]);

        $review = $this->makeReview('rejected');

        $response = $this->actingAs($admin)
            ->delete('/admin/reviews/' . $review->id);

        $response->assertRedirect();
        $this->assertDatabaseMissing('reviews', [
            'id' => $review->id,
        ]);
    }

    public function test_customer_cannot_moderate_review(): void
    {
        $customer = User::factory()->create([
            'role' => 'customer',
            'is_active' => true,
        ]);

        $review = $this->makeReview();

        $response = $this->actingAs($customer)
            ->put('/admin/reviews/' . $review->id . '/status', [
                'status' => 'approved',
            ]);

        $response->assertRedirect('/admin/login');
        $this->assertDatabaseHas('reviews', [
            'id' => $review->id,
            'status' => 'pending',
        ]);
    }
}
