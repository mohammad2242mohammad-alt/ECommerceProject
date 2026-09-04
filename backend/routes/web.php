<?php

use Illuminate\Support\Facades\Route;

use App\Http\Controllers\Admin\AdminAuthController;
use App\Http\Controllers\Admin\AdminDashboardController;

use App\Http\Controllers\Admin\AdminCategoryController;
use App\Http\Controllers\Admin\AdminCategoryAttributeController;

use App\Http\Controllers\Admin\AdminProductController;
use App\Http\Controllers\Admin\AdminProductImageController;
use App\Http\Controllers\Admin\AdminProductAttributeController;
use App\Http\Controllers\Admin\AdminProductVariantController;

use App\Http\Controllers\Admin\AdminOrderController;
use App\Http\Controllers\Admin\AdminCouponController;
use App\Http\Controllers\Admin\AdminSettingController;
use App\Http\Controllers\Admin\AdminReviewController;
use App\Http\Controllers\Admin\AdminUserController;
use App\Http\Controllers\Admin\AdminBannerController;


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

                Route::resource(
                    'categories',
                    AdminCategoryController::class
                )->except([
                    'show'
                ]);


                Route::post(
                    '/categories/{category}/toggle',
                    [AdminCategoryController::class,'toggle']
                )->name('categories.toggle');



                Route::get(
                    '/categories/{category}/attributes',
                    [AdminCategoryAttributeController::class,'index']
                )->name('categories.attributes.index');


                Route::post(
                    '/categories/{category}/attributes',
                    [AdminCategoryAttributeController::class,'store']
                )->name('categories.attributes.store');


                Route::put(
                    '/categories/{category}/attributes/{attribute}',
                    [AdminCategoryAttributeController::class,'update']
                )->name('categories.attributes.update');


                Route::delete(
                    '/categories/{category}/attributes/{attribute}',
                    [AdminCategoryAttributeController::class,'destroy']
                )->name('categories.attributes.destroy');



                /*
                |--------------------------------------------------------------------------
                | Products
                |--------------------------------------------------------------------------
                */

                Route::resource(
                    'products',
                    AdminProductController::class
                )->except([
                    'show'
                ]);


                Route::post(
                    '/products/{product}/toggle',
                    [AdminProductController::class,'toggle']
                )->name('products.toggle');



                Route::post(
                    '/products/{product}/images',
                    [AdminProductImageController::class,'store']
                )->name('products.images.store');


                Route::post(
                    '/products/{product}/images/{image}/primary',
                    [AdminProductImageController::class,'makePrimary']
                )->name('products.images.primary');


                Route::delete(
                    '/products/{product}/images/{image}',
                    [AdminProductImageController::class,'destroy']
                )->name('products.images.destroy');



                Route::post(
                    '/products/{product}/attributes',
                    [AdminProductAttributeController::class,'update']
                )->name('products.attributes.update');



                Route::post(
                    '/products/{product}/variants',
                    [AdminProductVariantController::class,'store']
                )->name('products.variants.store');


                Route::put(
                    '/products/{product}/variants/{variant}',
                    [AdminProductVariantController::class,'update']
                )->name('products.variants.update');


                Route::delete(
                    '/products/{product}/variants/{variant}',
                    [AdminProductVariantController::class,'destroy']
                )->name('products.variants.destroy');



                /*
                |--------------------------------------------------------------------------
                | Orders
                |--------------------------------------------------------------------------
                */

                Route::get(
                    '/orders',
                    [AdminOrderController::class,'index']
                )->name('orders.index');


                Route::get(
                    '/orders/{order}',
                    [AdminOrderController::class,'show']
                )->name('orders.show');


                Route::put(
                    '/orders/{order}/status',
                    [AdminOrderController::class,'updateStatus']
                )->name('orders.status');



                /*
                |--------------------------------------------------------------------------
                | Coupons
                |--------------------------------------------------------------------------
                */

                Route::resource(
                    'coupons',
                    AdminCouponController::class
                )->except([
                    'show'
                ]);


                Route::post(
                    '/coupons/{coupon}/toggle',
                    [AdminCouponController::class,'toggle']
                )->name('coupons.toggle');



                /*
                |--------------------------------------------------------------------------
                | Settings
                |--------------------------------------------------------------------------
                */

                Route::get(
                    '/settings',
                    [AdminSettingController::class,'index']
                )->name('settings.index');


                Route::put(
                    '/settings',
                    [AdminSettingController::class,'update']
                )->name('settings.update');



                /*
                |--------------------------------------------------------------------------
                | Reviews
                |--------------------------------------------------------------------------
                */

                Route::get(
                    '/reviews',
                    [AdminReviewController::class,'index']
                )->name('reviews.index');


                Route::put(
                    '/reviews/{review}/status',
                    [AdminReviewController::class,'updateStatus']
                )->name('reviews.status');


                Route::delete(
                    '/reviews/{review}',
                    [AdminReviewController::class,'destroy']
                )->name('reviews.destroy');



                /*
                |--------------------------------------------------------------------------
                | Users
                |--------------------------------------------------------------------------
                */

                Route::get(
                    '/users',
                    [AdminUserController::class,'index']
                )->name('users.index');


                Route::post(
                    '/users/{user}/toggle',
                    [AdminUserController::class,'toggle']
                )->name('users.toggle');



                /*
                |--------------------------------------------------------------------------
                | Banners
                |--------------------------------------------------------------------------
                */

                Route::resource(
                    'banners',
                    AdminBannerController::class
                )->except([
                    'show'
                ]);


                Route::post(
                    '/banners/{banner}/toggle',
                    [AdminBannerController::class,'toggle']
                )->name('banners.toggle');



            });

    });