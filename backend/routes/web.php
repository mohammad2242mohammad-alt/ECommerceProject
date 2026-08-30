<?php

use App\Http\Controllers\Admin\AdminAuthController;
use App\Http\Controllers\Admin\AdminCategoryAttributeController;
use App\Http\Controllers\Admin\AdminCategoryController;
use App\Http\Controllers\Admin\AdminDashboardController;
use App\Http\Controllers\Admin\AdminProductAttributeController;
use App\Http\Controllers\Admin\AdminProductController;
use App\Http\Controllers\Admin\AdminProductImageController;
use App\Http\Controllers\Admin\AdminProductVariantController;
use Illuminate\Support\Facades\Route;

Route::get('/', function () {
    return view('welcome');
});

Route::prefix('admin')
    ->name('admin.')
    ->group(function () {

        Route::get(
            '/login',
            [AdminAuthController::class, 'showLogin']
        )->name('login');

        Route::post(
            '/login',
            [AdminAuthController::class, 'login']
        )->name('login.submit');

        Route::middleware('admin.web')
            ->group(function () {

                Route::get(
                    '/',
                    [AdminDashboardController::class, 'index']
                )->name('dashboard');

                Route::post(
                    '/logout',
                    [AdminAuthController::class, 'logout']
                )->name('logout');

                /*
                |--------------------------------------------------------------------------
                | Categories
                |--------------------------------------------------------------------------
                */

                Route::get(
                    '/categories/{category}/attributes',
                    [AdminCategoryAttributeController::class, 'index']
                )->name('categories.attributes.index');

                Route::post(
                    '/categories/{category}/attributes',
                    [AdminCategoryAttributeController::class, 'store']
                )->name('categories.attributes.store');

                Route::put(
                    '/categories/{category}/attributes/{attribute}',
                    [AdminCategoryAttributeController::class, 'update']
                )->name('categories.attributes.update');

                Route::delete(
                    '/categories/{category}/attributes/{attribute}',
                    [AdminCategoryAttributeController::class, 'destroy']
                )->name('categories.attributes.destroy');

                Route::post(
                    '/categories/{category}/toggle',
                    [AdminCategoryController::class, 'toggle']
                )->name('categories.toggle');

                Route::resource(
                    'categories',
                    AdminCategoryController::class
                )->except([
                    'show',
                ]);

                /*
                |--------------------------------------------------------------------------
                | Product Images
                |--------------------------------------------------------------------------
                */

                Route::post(
                    '/products/{product}/images',
                    [AdminProductImageController::class, 'store']
                )->name('products.images.store');

                Route::post(
                    '/products/{product}/images/{image}/primary',
                    [AdminProductImageController::class, 'makePrimary']
                )->name('products.images.primary');

                Route::delete(
                    '/products/{product}/images/{image}',
                    [AdminProductImageController::class, 'destroy']
                )->name('products.images.destroy');

                /*
                |--------------------------------------------------------------------------
                | Product Attributes
                |--------------------------------------------------------------------------
                */

                Route::post(
                    '/products/{product}/attributes',
                    [AdminProductAttributeController::class, 'update']
                )->name('products.attributes.update');

                /*
                |--------------------------------------------------------------------------
                | Product Variants
                |--------------------------------------------------------------------------
                */

                Route::post(
                    '/products/{product}/variants',
                    [AdminProductVariantController::class, 'store']
                )->name('products.variants.store');

                Route::put(
                    '/products/{product}/variants/{variant}',
                    [AdminProductVariantController::class, 'update']
                )->name('products.variants.update');

                Route::delete(
                    '/products/{product}/variants/{variant}',
                    [AdminProductVariantController::class, 'destroy']
                )->name('products.variants.destroy');

                /*
                |--------------------------------------------------------------------------
                | Products
                |--------------------------------------------------------------------------
                */

                Route::post(
                    '/products/{product}/toggle',
                    [AdminProductController::class, 'toggle']
                )->name('products.toggle');

                Route::resource(
                    'products',
                    AdminProductController::class
                )->except([
                    'show',
                ]);
            });
    });