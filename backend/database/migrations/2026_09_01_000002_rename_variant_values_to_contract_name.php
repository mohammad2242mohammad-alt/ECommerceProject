<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        if (
            Schema::hasTable('variant_values') &&
            !Schema::hasTable('product_variant_values')
        ) {
            Schema::rename(
                'variant_values',
                'product_variant_values'
            );
        }
    }

    public function down(): void
    {
        if (
            Schema::hasTable('product_variant_values') &&
            !Schema::hasTable('variant_values')
        ) {
            Schema::rename(
                'product_variant_values',
                'variant_values'
            );
        }
    }
};
