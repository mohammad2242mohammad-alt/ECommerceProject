<?php

use App\Http\Controllers\Admin\AdminAuthController;
use App\Http\Controllers\Admin\AdminCategoryController;
use App\Http\Controllers\Admin\AdminDashboardController;
use App\Http\Controllers\Admin\AdminProductController;
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