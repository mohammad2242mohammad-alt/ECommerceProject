<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Add the views column only if it does not already exist.
     */
    public function up(): void
    {
        if (!Schema::hasColumn('products', 'views')) {
            Schema::table('products', function (Blueprint $table) {
                $table->unsignedInteger('views')
                    ->default(0)
                    ->after('rating_count');
            });
        }
    }

    /**
     * Remove the views column only if it exists.
     */
    public function down(): void
    {
        if (Schema::hasColumn('products', 'views')) {
            Schema::table('products', function (Blueprint $table) {
                $table->dropColumn('views');
            });
        }
    }
};