<?php

namespace Tests\Feature;

use App\Models\Category;
use App\Models\Product;
use App\Models\ProductImage;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Http\UploadedFile;
use Illuminate\Support\Facades\Storage;
use Tests\TestCase;

class ProductImageContractTest extends TestCase
{
    use RefreshDatabase;

    private function makeProduct(): Product
    {
        $category = Category::create([
            'name' => 'Image category',
            'slug' => 'image-category-' . uniqid(),
            'is_active' => true,
        ]);

        return Product::create([
            'category_id' => $category->id,
            'name' => 'Image product',
            'slug' => 'image-product-' . uniqid(),
            'sku' => 'IMAGE-' . uniqid(),
            'price' => 1000,
            'stock' => 10,
            'status' => 'active',
        ]);
    }

    private function fakeImage(): UploadedFile
    {
        return UploadedFile::fake()->createWithContent(
            'product.gif',
            base64_decode('R0lGODlhAQABAAD/ACwAAAAAAQABAAACADs=')
        );
    }

    public function test_public_product_images_are_returned_in_sort_order(): void
    {
        Storage::fake('public');
        $product = $this->makeProduct();

        ProductImage::create([
            'product_id' => $product->id,
            'path' => 'products/second.jpg',
            'alt_text' => 'Second',
            'sort_order' => 2,
            'is_primary' => false,
        ]);
        ProductImage::create([
            'product_id' => $product->id,
            'path' => 'products/first.jpg',
            'alt_text' => 'First',
            'sort_order' => 1,
            'is_primary' => true,
        ]);

        $this->getJson("/api/products/{$product->id}/images")
            ->assertOk()
            ->assertJsonPath('success', true)
            ->assertJsonPath('data.0.alt_text', 'First')
            ->assertJsonPath('data.1.alt_text', 'Second');

        $response = $this->getJson("/api/products/{$product->id}/images");
        $this->assertTrue((bool) $response->json('data.0.is_primary'));
    }

    public function test_admin_can_upload_product_image_and_first_image_becomes_primary(): void
    {
        Storage::fake('public');
        $admin = User::factory()->create(['role' => 'admin']);
        $product = $this->makeProduct();

        $response = $this->actingAs($admin, 'sanctum')
            ->post("/api/products/{$product->id}/images", [
                'image' => $this->fakeImage(),
                'alt_text' => 'Product image',
                'sort_order' => 1,
            ])
            ->assertOk()
            ->assertJsonPath('success', true)
            ->assertJsonPath('data.is_primary', true);

        $imageId = $response->json('data.id');
        $image = ProductImage::findOrFail($imageId);

        Storage::disk('public')->assertExists($image->path);
        $this->assertTrue((bool) $image->is_primary);
    }

    public function test_admin_can_delete_primary_image_and_next_image_becomes_primary(): void
    {
        Storage::fake('public');
        $admin = User::factory()->create(['role' => 'admin']);
        $product = $this->makeProduct();

        $primary = ProductImage::create([
            'product_id' => $product->id,
            'path' => 'products/primary.jpg',
            'alt_text' => 'Primary',
            'sort_order' => 1,
            'is_primary' => true,
        ]);
        $next = ProductImage::create([
            'product_id' => $product->id,
            'path' => 'products/next.jpg',
            'alt_text' => 'Next',
            'sort_order' => 2,
            'is_primary' => false,
        ]);

        $this->actingAs($admin, 'sanctum')
            ->deleteJson("/api/images/{$primary->id}")
            ->assertOk()
            ->assertJsonPath('success', true);

        $this->assertDatabaseMissing('product_images', ['id' => $primary->id]);
        $this->assertDatabaseHas('product_images', [
            'id' => $next->id,
            'is_primary' => true,
        ]);
    }
}
