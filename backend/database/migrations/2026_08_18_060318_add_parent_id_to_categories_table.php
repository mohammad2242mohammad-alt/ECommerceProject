<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        if (!Schema::hasColumn('categories', 'parent_id')) {
            Schema::table('categories', function (Blueprint $table) {
                $table->unsignedBigInteger('parent_id')
                    ->nullable()
                    ->after('id');

                $table->foreign('parent_id')
                    ->references('id')
                    ->on('categories')
                    ->nullOnDelete();
            });
        }
    }

    public function down(): void
    {
        // Intentionally left empty.
        // parent_id may already belong to the original categories schema.
    }
};