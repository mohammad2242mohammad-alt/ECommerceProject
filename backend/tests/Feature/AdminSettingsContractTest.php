<?php

namespace Tests\Feature;

use App\Models\Setting;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class AdminSettingsContractTest extends TestCase
{
    use RefreshDatabase;

    public function test_admin_can_update_shipping_settings(): void
    {
        $admin = User::factory()->create([
            'role' => 'admin',
            'is_active' => true,
        ]);

        $response = $this->actingAs($admin)
            ->put('/admin/settings', [
                'shipping_price' => 45000,
                'free_shipping_threshold' => 1000000,
            ]);

        $response->assertRedirect();

        $this->assertDatabaseHas('settings', [
            'key' => 'shipping_price',
            'value' => '45000',
            'type' => 'number',
        ]);

        $this->assertDatabaseHas('settings', [
            'key' => 'free_shipping_threshold',
            'value' => '1000000',
            'type' => 'number',
        ]);
    }

    public function test_admin_settings_reject_negative_shipping_values(): void
    {
        $admin = User::factory()->create([
            'role' => 'admin',
            'is_active' => true,
        ]);

        $response = $this->actingAs($admin)
            ->from('/admin/settings')
            ->put('/admin/settings', [
                'shipping_price' => -1,
                'free_shipping_threshold' => 1000000,
            ]);

        $response->assertSessionHasErrors('shipping_price');
        $this->assertDatabaseMissing('settings', [
            'key' => 'shipping_price',
            'value' => '-1',
        ]);
    }

    public function test_customer_cannot_update_admin_settings(): void
    {
        $customer = User::factory()->create([
            'role' => 'customer',
            'is_active' => true,
        ]);

        $response = $this->actingAs($customer)
            ->put('/admin/settings', [
                'shipping_price' => 45000,
                'free_shipping_threshold' => 1000000,
            ]);

        $response->assertRedirect('/admin/login');
        $this->assertDatabaseMissing('settings', [
            'key' => 'shipping_price',
            'value' => '45000',
        ]);
    }
}
