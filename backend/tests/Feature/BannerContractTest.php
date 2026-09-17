<?php

namespace Tests\Feature;

use App\Models\Banner;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class BannerContractTest extends TestCase
{
    use RefreshDatabase;

    public function test_public_banner_list_returns_only_active_and_current_banners_in_sort_order(): void
    {
        Banner::create([
            'title' => 'Second',
            'image' => 'second.jpg',
            'sort_order' => 2,
            'is_active' => true,
        ]);
        Banner::create([
            'title' => 'First',
            'image' => 'first.jpg',
            'sort_order' => 1,
            'is_active' => true,
        ]);
        Banner::create([
            'title' => 'Inactive',
            'image' => 'inactive.jpg',
            'sort_order' => 0,
            'is_active' => false,
        ]);
        Banner::create([
            'title' => 'Future',
            'image' => 'future.jpg',
            'sort_order' => 0,
            'is_active' => true,
            'starts_at' => now()->addDay(),
        ]);
        Banner::create([
            'title' => 'Expired',
            'image' => 'expired.jpg',
            'sort_order' => 0,
            'is_active' => true,
            'ends_at' => now()->subDay(),
        ]);

        $response = $this->getJson('/api/banners')
            ->assertOk()
            ->assertJsonPath('success', true);

        $data = $response->json('data');

        $this->assertCount(2, $data);
        $this->assertSame('First', $data[0]['title']);
        $this->assertSame('Second', $data[1]['title']);
    }

    public function test_public_banner_list_accepts_current_banner_with_open_ended_dates(): void
    {
        Banner::create([
            'title' => 'Always on',
            'image' => 'always.jpg',
            'sort_order' => 1,
            'is_active' => true,
            'starts_at' => null,
            'ends_at' => null,
        ]);

        $this->getJson('/api/banners')
            ->assertOk()
            ->assertJsonPath('data.0.title', 'Always on');
    }
}
