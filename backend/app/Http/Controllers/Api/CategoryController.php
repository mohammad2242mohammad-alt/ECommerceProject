<?php

namespace App\Http\Controllers\Api;

use App\Helpers\ApiResponseHelper;
use App\Http\Controllers\Controller;
use App\Http\Resources\CategoryResource;
use App\Models\Category;
use Illuminate\Http\JsonResponse;

class CategoryController extends Controller
{
    /**
     * دریافت دسته‌های اصلی فعال، همراه با زیردسته‌های فعال آن‌ها
     */
    public function index(): JsonResponse
    {
        // دریافت دسته‌های اصلی فعال و مرتب‌سازی آن‌ها بر اساس ترتیب نمایش
        $categories = Category::with(['children' => function ($query) {
            // دریافت فقط زیردسته‌های فعال و مرتب‌سازی آن‌ها
            $query->where('is_active', true)
                ->orderBy('sort_order');
        }])
            ->whereNull('parent_id')
            ->where('is_active', true)
            ->orderBy('sort_order')
            ->get();

        // تبدیل اطلاعات دسته‌بندی‌ها به خروجی استاندارد Resource
        $categoryResource = CategoryResource::collection($categories);

        // ارسال پاسخ موفق با ساختار یکپارچه پروژه
        return ApiResponseHelper::success(
            data: $categoryResource,
            message: 'لیست دسته‌بندی‌ها با موفقیت دریافت شد'
        );
    }
}