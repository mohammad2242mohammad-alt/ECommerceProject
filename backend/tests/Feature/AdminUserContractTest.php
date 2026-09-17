<?php

namespace Tests\Feature;

use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class AdminUserContractTest extends TestCase
{
    use RefreshDatabase;

    public function test_admin_can_toggle_customer_status(): void
    {
        $admin = User::factory()->create([
            'role' => 'admin',
            'is_active' => true,
        ]);

        $customer = User::factory()->create([
            'role' => 'customer',
            'is_active' => true,
        ]);

        $response = $this->actingAs($admin)
            ->post('/admin/users/' . $customer->id . '/toggle');

        $response->assertRedirect();
        $this->assertDatabaseHas('users', [
            'id' => $customer->id,
            'is_active' => false,
        ]);
    }

    public function test_admin_can_toggle_user_back_to_active(): void
    {
        $admin = User::factory()->create([
            'role' => 'admin',
            'is_active' => true,
        ]);

        $customer = User::factory()->create([
            'role' => 'customer',
            'is_active' => false,
        ]);

        $response = $this->actingAs($admin)
            ->post('/admin/users/' . $customer->id . '/toggle');

        $response->assertRedirect();
        $this->assertDatabaseHas('users', [
            'id' => $customer->id,
            'is_active' => true,
        ]);
    }

    public function test_customer_cannot_toggle_another_user_status(): void
    {
        $customer = User::factory()->create([
            'role' => 'customer',
            'is_active' => true,
        ]);

        $target = User::factory()->create([
            'role' => 'customer',
            'is_active' => true,
        ]);

        $response = $this->actingAs($customer)
            ->post('/admin/users/' . $target->id . '/toggle');

        $response->assertRedirect('/admin/login');
        $this->assertDatabaseHas('users', [
            'id' => $target->id,
            'is_active' => true,
        ]);
    }
}
