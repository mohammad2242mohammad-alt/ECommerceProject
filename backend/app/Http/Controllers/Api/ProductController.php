<?php

namespace App\Http\Controllers\Api;

<<<<<<< HEAD
use App\Http\Controllers\Controller;
use App\Http\Requests\ProductIndexRequest;
use App\Http\Resources\ProductResource;
use App\Http\Resources\ProductDetailResource;
use App\Models\Product;
use Illuminate\Http\JsonResponse;

class ProductController extends Controller
{
    public function index(ProductIndexRequest $request): JsonResponse
    {
        $validated = $request->validated();


        $query = Product::query()
            ->with('category')
            ->where('status', 'active');


        if (!empty($validated['category_id'])) {

            $query->where('category_id', $validated['category_id']);

        }


        if (!empty($validated['search'])) {

            $search = $validated['search'];

            $query->where(function ($query) use ($search) {

                $query->where('name', 'like', "%{$search}%")
                    ->orWhere('sku', 'like', "%{$search}%")
                    ->orWhere('short_description', 'like', "%{$search}%")
                    ->orWhere('description', 'like', "%{$search}%");

            });

        }


        if (isset($validated['min_price'])) {

            $query->where('price', '>=', $validated['min_price']);

        }


        if (isset($validated['max_price'])) {

            $query->where('price', '<=', $validated['max_price']);

        }


        switch ($validated['sort'] ?? 'newest') {

            case 'oldest':

                $query->orderBy('created_at', 'asc');

                break;


            case 'price_asc':

                $query->orderBy('price', 'asc');

                break;


            case 'price_desc':

                $query->orderBy('price', 'desc');

                break;


            case 'rating_desc':

                $query->orderBy('rating_average', 'desc');

                break;


            case 'newest':

            default:

                $query->orderBy('created_at', 'desc');

                break;

        }


        $perPage = $validated['per_page'] ?? 15;


        $products = $query->paginate($perPage);


        return response()->json([

            'success' => true,

            'message' => 'Success',

            'data' => [

                'items' => ProductResource::collection($products->items()),


                'pagination' => [

                    'current_page' => $products->currentPage(),

                    'per_page' => $products->perPage(),

                    'total' => $products->total(),

                    'last_page' => $products->lastPage(),

                    'from' => $products->firstItem(),

                    'to' => $products->lastItem(),

                ],

            ],

        ]);
    }



    public function show($id): JsonResponse
    {
        $product = Product::with([

            'category',

            'images',

            'attributeValues.attribute',

            'variants.values.attribute'

        ])

        ->where('status', 'active')

        ->findOrFail($id);



        return response()->json([

            'success' => true,

            'message' => 'Success',

            'data' => new ProductDetailResource($product),

        ]);
=======
use App\Helpers\ApiResponseHelper;
use App\Http\Controllers\Controller;
use App\Models\Product;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

/**
 * کنترلر API محصولات فروشگاه.
 *
 * وظایف فعلی:
 * - دریافت لیست محصولات
 * - جستجوی محصولات
 * - فیلتر بر اساس دسته‌بندی
 * - فیلتر بر اساس محدوده قیمت
 * - مرتب‌سازی
 * - Pagination
 *
 * نکته:
 * منطق دریافت و فیلتر اطلاعات در Backend انجام می‌شود
 * تا Flutter فقط مصرف‌کننده API باشد.
 */
class ProductController extends Controller
{
    /**
     * دریافت لیست محصولات.
     *
     * پارامترهای قابل استفاده:
     * - category_id
     * - search
     * - page
     * - per_page
     * - sort
     * - min_price
     * - max_price
     */
    public function index(Request $request): JsonResponse
    {
        // Query اولیه محصولات را می‌سازیم.
        // فقط محصولات فعال برای فروشگاه نمایش داده می‌شوند.
        $query = Product::query()
            ->with('category')
            ->where('is_active', true);

        // فیلتر بر اساس دسته‌بندی.
        if ($request->filled('category_id')) {
            $query->where('category_id', $request->integer('category_id'));
        }

        // جستجو در نام، توضیحات و slug محصول.
        if ($request->filled('search')) {
            $search = $request->string('search')->toString();

            $query->where(function ($q) use ($search) {
                $q->where('name', 'like', "%{$search}%")
                    ->orWhere('description', 'like', "%{$search}%")
                    ->orWhere('slug', 'like', "%{$search}%");
            });
        }

        // حداقل قیمت.
        if ($request->filled('min_price')) {
            $query->where('price', '>=', $request->input('min_price'));
        }

        // حداکثر قیمت.
        if ($request->filled('max_price')) {
            $query->where('price', '<=', $request->input('max_price'));
        }

        // مرتب‌سازی محصولات.
        // مقدار پیش‌فرض جدیدترین محصولات است.
        $sort = $request->input('sort', 'latest');

        switch ($sort) {
            case 'price_asc':
                $query->orderBy('price', 'asc');
                break;

            case 'price_desc':
                $query->orderBy('price', 'desc');
                break;

            case 'rating':
                $query->orderBy('rating', 'desc');
                break;

            case 'views':
                $query->orderBy('views', 'desc');
                break;

            case 'latest':
            default:
                $query->latest();
                break;
        }

        // تعداد محصولات در هر صفحه.
        // برای جلوگیری از درخواست‌های سنگین، حداکثر 100 محصول مجاز است.
        $perPage = min(
            max($request->integer('per_page', 12), 1),
            100
        );

        // دریافت محصولات به صورت صفحه‌بندی‌شده.
        $products = $query->paginate($perPage);

        // پاسخ استاندارد API پروژه.
        return ApiResponseHelper::success(
            data: [
                'items' => $products->items(),
                'pagination' => [
                    'current_page' => $products->currentPage(),
                    'last_page' => $products->lastPage(),
                    'per_page' => $products->perPage(),
                    'total' => $products->total(),
                    'from' => $products->firstItem(),
                    'to' => $products->lastItem(),
                ],
            ],
            message: 'لیست محصولات با موفقیت دریافت شد'
        );
>>>>>>> b085672 (feat: complete product api backend foundation)
    }
}