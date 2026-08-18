<?php

use App\Http\Controllers\Api\CategoryController;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;

/*
|--------------------------------------------------------------------------
| مسیرهای API پروژه
|--------------------------------------------------------------------------
*/

// مسیر دریافت اطلاعات کاربر لاگین‌شده از طریق Sanctum
Route::get('/user', function (Request $request) {
    return $request->user();
})->middleware('auth:sanctum');

// مسیر دریافت دسته‌بندی‌های فعال همراه با زیردسته‌های آن‌ها
Route::get('/categories', [CategoryController::class, 'index']);