<?php

use App\Http\Controllers\Api\AddressController;
use App\Http\Controllers\Api\AuthController;
use App\Http\Controllers\Api\BannerController;
use App\Http\Controllers\Api\CartController;
use App\Http\Controllers\Api\CategoryAttributeController;
use App\Http\Controllers\Api\CategoryController;
use App\Http\Controllers\Api\CheckoutController;
use App\Http\Controllers\Api\CouponController;
use App\Http\Controllers\Api\FavoriteController;
use App\Http\Controllers\Api\HomeController;
use App\Http\Controllers\Api\OrderController;
use App\Http\Controllers\Api\PaymentController;
use App\Http\Controllers\Api\ProductAttributeValueController;
use App\Http\Controllers\Api\ProductController;
use App\Http\Controllers\Api\ProductImageController;
use App\Http\Controllers\Api\ProductVariantController;
use App\Http\Controllers\Api\ReviewController;
use App\Http\Controllers\Api\SettingController;
use App\Http\Controllers\Api\VariantValueController;
use Illuminate\Support\Facades\Route;


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
| Public Store APIs
|--------------------------------------------------------------------------
*/

Route::get('/home', [HomeController::class, 'index']);

Route::get('/categories', [CategoryController::class, 'index']);

Route::get('/categories/{id}', [CategoryController::class, 'show']);

Route::get('/products', [ProductController::class, 'index']);

Route::get('/products/{id}', [ProductController::class, 'show']);

Route::get('/products/{productId}/reviews', [ReviewController::class, 'index']);

Route::get('/banners', [BannerController::class, 'index']);

Route::get('/settings', [SettingController::class, 'index']);


/*
|--------------------------------------------------------------------------
| Product Data
|--------------------------------------------------------------------------
*/

Route::get('/categories/{categoryId}/attributes',
    [CategoryAttributeController::class, 'index']
);

Route::get('/products/{productId}/attributes',
    [ProductAttributeValueController::class, 'index']
);

Route::get('/products/{productId}/images',
    [ProductImageController::class, 'index']
);

Route::get('/products/{productId}/variants',
    [ProductVariantController::class, 'index']
);

Route::get('/variants/{variantId}/values',
    [VariantValueController::class, 'index']
);


/*
|--------------------------------------------------------------------------
| Authenticated Customer APIs
|--------------------------------------------------------------------------
*/

Route::middleware('auth:sanctum')->group(function () {


    /*
    |--------------------------------------------------------------------------
    | Cart
    |--------------------------------------------------------------------------
    */

    Route::get('/cart',
        [CartController::class, 'index']
    );

    Route::post('/cart/items',
        [CartController::class, 'store']
    );

    Route::put('/cart/items/{id}',
        [CartController::class, 'update']
    );

    Route::delete('/cart/items/{id}',
        [CartController::class, 'destroy']
    );

    Route::delete('/cart',
        [CartController::class, 'clear']
    );



    /*
    |--------------------------------------------------------------------------
    | Coupon / Checkout
    |--------------------------------------------------------------------------
    */

    Route::post('/coupons/validate',
        [CouponController::class, 'validateCoupon']
    );

    Route::post('/checkout/calculate',
        [CheckoutController::class, 'calculate']
    );



    /*
    |--------------------------------------------------------------------------
    | Addresses
    |--------------------------------------------------------------------------
    */

    Route::get('/addresses',
        [AddressController::class, 'index']
    );

    Route::post('/addresses',
        [AddressController::class, 'store']
    );

    Route::get('/addresses/{id}',
        [AddressController::class, 'show']
    );

    Route::put('/addresses/{id}',
        [AddressController::class, 'update']
    );

    Route::delete('/addresses/{id}',
        [AddressController::class, 'destroy']
    );



    /*
    |--------------------------------------------------------------------------
    | Favorites
    |--------------------------------------------------------------------------
    */

    Route::get('/favorites',
        [FavoriteController::class, 'index']
    );

    Route::post('/favorites',
        [FavoriteController::class, 'store']
    );

    Route::delete('/favorites/{productId}',
        [FavoriteController::class, 'destroy']
    );



    /*
    |--------------------------------------------------------------------------
    | Reviews
    |--------------------------------------------------------------------------
    */

    Route::post('/products/{productId}/reviews',
        [ReviewController::class, 'store']
    );



    /*
    |--------------------------------------------------------------------------
    | Orders
    |--------------------------------------------------------------------------
    */

    Route::get('/orders',
        [OrderController::class, 'index']
    );

    Route::post('/orders',
        [OrderController::class, 'store']
    );

    Route::get('/orders/{id}',
        [OrderController::class, 'show']
    );

    Route::post('/orders/{id}/cancel',
        [OrderController::class, 'cancel']
    );



    /*
    |--------------------------------------------------------------------------
    | Payments
    |--------------------------------------------------------------------------
    */

    Route::post('/payments/{orderId}/start',
        [PaymentController::class, 'start']
    );

    Route::get('/payments/{orderId}/status',
        [PaymentController::class, 'status']
    );

});



/*
|--------------------------------------------------------------------------
| Admin APIs
|--------------------------------------------------------------------------
*/

Route::middleware([
    'auth:sanctum',
    'admin',
])->group(function () {


    Route::post('/categories/{categoryId}/attributes',
        [CategoryAttributeController::class, 'store']
    );


    Route::put('/attributes/{id}',
        [CategoryAttributeController::class, 'update']
    );


    Route::delete('/attributes/{id}',
        [CategoryAttributeController::class, 'destroy']
    );



    Route::post('/products/{productId}/attributes',
        [ProductAttributeValueController::class, 'store']
    );


    Route::post('/products/{productId}/images',
        [ProductImageController::class, 'store']
    );


    Route::delete('/images/{id}',
        [ProductImageController::class, 'destroy']
    );


    Route::post('/products/{productId}/variants',
        [ProductVariantController::class, 'store']
    );


    Route::put('/variants/{id}',
        [ProductVariantController::class, 'update']
    );


    Route::delete('/variants/{id}',
        [ProductVariantController::class, 'destroy']
    );


    Route::post('/variants/{variantId}/values',
        [VariantValueController::class, 'store']
    );


    Route::put('/variant-values/{id}',
        [VariantValueController::class, 'update']
    );


    Route::delete('/variant-values/{id}',
        [VariantValueController::class, 'destroy']
    );

});
