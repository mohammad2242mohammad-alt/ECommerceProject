<?php

use App\Http\Controllers\Api\AuthController;
use App\Http\Controllers\Api\CategoryController;
use App\Http\Controllers\Api\ProductController;
use App\Http\Controllers\Api\CategoryAttributeController;
use App\Http\Controllers\Api\ProductAttributeValueController;
use App\Http\Controllers\Api\ProductVariantController;
use App\Http\Controllers\Api\VariantValueController;
use App\Http\Controllers\Api\ProductImageController;
use App\Http\Controllers\Api\CartController;
use Illuminate\Support\Facades\Route;
use App\Http\Controllers\Api\OrderController;


/*
|--------------------------------------------------------------------------
| Authentication
|--------------------------------------------------------------------------
*/

Route::prefix('auth')->group(function () {

    Route::post('/register', [AuthController::class, 'register']);

    Route::post('/login', [AuthController::class, 'login']);


    Route::middleware('auth:sanctum')->group(function () {

        Route::post('/logout', [AuthController::class, 'logout']);

        Route::get('/me', [AuthController::class, 'me']);

    });

});



/*
|--------------------------------------------------------------------------
| Categories
|--------------------------------------------------------------------------
*/

Route::get('/categories', [CategoryController::class, 'index']);

Route::get('/categories/{id}', [CategoryController::class, 'show']);



/*
|--------------------------------------------------------------------------
| Category Attributes
|--------------------------------------------------------------------------
*/

Route::get(
    '/categories/{categoryId}/attributes',
    [CategoryAttributeController::class, 'index']
);

Route::post(
    '/categories/{categoryId}/attributes',
    [CategoryAttributeController::class, 'store']
);

Route::put(
    '/attributes/{id}',
    [CategoryAttributeController::class, 'update']
);

Route::delete(
    '/attributes/{id}',
    [CategoryAttributeController::class, 'destroy']
);



/*
|--------------------------------------------------------------------------
| Products
|--------------------------------------------------------------------------
*/

Route::get('/products', [ProductController::class, 'index']);

Route::get('/products/{id}', [ProductController::class, 'show']);



/*
|--------------------------------------------------------------------------
| Product Attributes
|--------------------------------------------------------------------------
*/

Route::get(
    '/products/{productId}/attributes',
    [ProductAttributeValueController::class, 'index']
);

Route::post(
    '/products/{productId}/attributes',
    [ProductAttributeValueController::class, 'store']
);



/*
|--------------------------------------------------------------------------
| Product Images
|--------------------------------------------------------------------------
*/

Route::get(
    '/products/{productId}/images',
    [ProductImageController::class, 'index']
);

Route::post(
    '/products/{productId}/images',
    [ProductImageController::class, 'store']
);

Route::delete(
    '/images/{id}',
    [ProductImageController::class, 'destroy']
);



/*
|--------------------------------------------------------------------------
| Product Variants
|--------------------------------------------------------------------------
*/

Route::get(
    '/products/{productId}/variants',
    [ProductVariantController::class, 'index']
);

Route::post(
    '/products/{productId}/variants',
    [ProductVariantController::class, 'store']
);

Route::put(
    '/variants/{id}',
    [ProductVariantController::class, 'update']
);

Route::delete(
    '/variants/{id}',
    [ProductVariantController::class, 'destroy']
);



/*
|--------------------------------------------------------------------------
| Variant Values
|--------------------------------------------------------------------------
*/

Route::get(
    '/variants/{variantId}/values',
    [VariantValueController::class, 'index']
);

Route::post(
    '/variants/{variantId}/values',
    [VariantValueController::class, 'store']
);

Route::put(
    '/variant-values/{id}',
    [VariantValueController::class, 'update']
);

Route::delete(
    '/variant-values/{id}',
    [VariantValueController::class, 'destroy']
);



/*
|--------------------------------------------------------------------------
| Cart
|--------------------------------------------------------------------------
*/

Route::get(
    '/cart',
    [CartController::class, 'index']
);


Route::post(
    '/cart/items',
    [CartController::class, 'store']
);


Route::put(
    '/cart/items/{id}',
    [CartController::class, 'update']
);


Route::delete(
    '/cart/items/{id}',
    [CartController::class, 'destroy']
);

/*
|--------------------------------------------------------------------------
| Orders
|--------------------------------------------------------------------------
*/

Route::post(
    '/orders',
    [OrderController::class,'store']
);