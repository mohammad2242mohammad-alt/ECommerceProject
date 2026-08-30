<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\Category;
use App\Models\CategoryAttribute;
use App\Models\Product;
use App\Models\ProductAttributeValue;
use App\Models\VariantValue;
use Illuminate\Http\RedirectResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Validation\Rule;
use Illuminate\View\View;

class AdminProductController extends Controller
{
    public function index(Request $request): View
    {
        $query = Product::query()
            ->with('category')
            ->latest();

        if ($request->filled('search')) {
            $search = trim(
                (string)
                $request->input('search')
            );

            $query->where(
                function ($query) use ($search) {
                    $query
                        ->where(
                            'name',
                            'like',
                            "%{$search}%"
                        )
                        ->orWhere(
                            'sku',
                            'like',
                            "%{$search}%"
                        )
                        ->orWhere(
                            'slug',
                            'like',
                            "%{$search}%"
                        );
                }
            );
        }

        if ($request->filled('category_id')) {
            $query->where(
                'category_id',
                $request->integer('category_id')
            );
        }

        if ($request->filled('status')) {
            $query->where(
                'status',
                (string)
                $request->input('status')
            );
        }

        $products = $query
            ->paginate(20)
            ->withQueryString();

        $categories = Category::query()
            ->orderBy('name')
            ->get();

        return view(
            'admin.products.index',
            compact(
                'products',
                'categories'
            )
        );
    }

    public function create(): View
    {
        $categories = Category::query()
            ->orderBy('name')
            ->get();

        return view(
            'admin.products.create',
            compact('categories')
        );
    }

    public function store(
        Request $request
    ): RedirectResponse {
        $validated = $this->validateProduct(
            $request
        );

        $product = Product::create(
            $validated
        );

        return redirect()
            ->route(
                'admin.products.edit',
                $product
            )
            ->with(
                'success',
                'محصول ایجاد شد. حالا می‌توانید تصویر، مشخصات و تنوع‌های آن را اضافه کنید.'
            );
    }

    public function edit(
        Product $product
    ): View {
        $product->load([
            'images' => function ($query) {
                $query
                    ->orderByDesc('is_primary')
                    ->orderBy('sort_order')
                    ->orderBy('id');
            },

            'attributeValues.attribute',

            'variants' => function ($query) {
                $query
                    ->with(
                        'values.attribute'
                    )
                    ->orderBy('id');
            },
        ]);

        $categories = Category::query()
            ->orderBy('name')
            ->get();

        $categoryAttributes =
            CategoryAttribute::query()
                ->where(
                    'category_id',
                    $product->category_id
                )
                ->orderBy('sort_order')
                ->orderBy('name')
                ->get();

        $attributeValueMap =
            $product
                ->attributeValues
                ->keyBy(
                    'category_attribute_id'
                );

        return view(
            'admin.products.edit',
            compact(
                'product',
                'categories',
                'categoryAttributes',
                'attributeValueMap'
            )
        );
    }

    public function update(
        Request $request,
        Product $product
    ): RedirectResponse {
        $oldCategoryId =
            $product->category_id;

        $validated = $this->validateProduct(
            $request,
            $product
        );

        $product->update(
            $validated
        );

        if (
            $oldCategoryId !==
            $product->category_id
        ) {
            $validAttributeIds =
                CategoryAttribute::where(
                    'category_id',
                    $product->category_id
                )->pluck('id');

            if ($validAttributeIds->isEmpty()) {
                ProductAttributeValue::query()
                    ->where(
                        'product_id',
                        $product->id
                    )
                    ->delete();

                VariantValue::query()
                    ->whereIn(
                        'product_variant_id',
                        $product
                            ->variants()
                            ->pluck('id')
                    )
                    ->delete();
            } else {
                ProductAttributeValue::query()
                    ->where(
                        'product_id',
                        $product->id
                    )
                    ->whereNotIn(
                        'category_attribute_id',
                        $validAttributeIds
                    )
                    ->delete();

                VariantValue::query()
                    ->whereIn(
                        'product_variant_id',
                        $product
                            ->variants()
                            ->pluck('id')
                    )
                    ->whereNotIn(
                        'category_attribute_id',
                        $validAttributeIds
                    )
                    ->delete();
            }
        }

        return redirect()
            ->route(
                'admin.products.edit',
                $product
            )
            ->with(
                'success',
                'محصول با موفقیت ویرایش شد.'
            );
    }

    public function toggle(
        Product $product
    ): RedirectResponse {
        $product->update([
            'status' =>
                $product->status === 'active'
                    ? 'inactive'
                    : 'active',
        ]);

        return back()->with(
            'success',
            'وضعیت محصول تغییر کرد.'
        );
    }

    public function destroy(
        Product $product
    ): RedirectResponse {
        $hasOrders =
            DB::table('order_items')
                ->where(
                    'product_id',
                    $product->id
                )
                ->exists();

        $hasCartItems =
            DB::table('cart_items')
                ->where(
                    'product_id',
                    $product->id
                )
                ->exists();

        $hasFavorites =
            DB::table('favorites')
                ->where(
                    'product_id',
                    $product->id
                )
                ->exists();

        $hasReviews =
            DB::table('reviews')
                ->where(
                    'product_id',
                    $product->id
                )
                ->exists();

        if (
            $hasOrders ||
            $hasCartItems ||
            $hasFavorites ||
            $hasReviews
        ) {
            return back()->withErrors([
                'delete' =>
                    'این محصول سابقه عملیاتی دارد و قابل حذف نیست. آن را غیرفعال کنید.',
            ]);
        }

        $product->delete();

        return redirect()
            ->route('admin.products.index')
            ->with(
                'success',
                'محصول با موفقیت حذف شد.'
            );
    }

    private function validateProduct(
        Request $request,
        ?Product $product = null
    ): array {
        return $request->validate([
            'category_id' => [
                'required',
                'integer',
                'exists:categories,id',
            ],

            'name' => [
                'required',
                'string',
                'max:255',
            ],

            'slug' => [
                'required',
                'string',
                'max:255',
                'regex:/^[a-z0-9]+(?:-[a-z0-9]+)*$/',

                Rule::unique(
                    'products',
                    'slug'
                )->ignore(
                    $product?->id
                ),
            ],

            'sku' => [
                'required',
                'string',
                'max:255',

                Rule::unique(
                    'products',
                    'sku'
                )->ignore(
                    $product?->id
                ),
            ],

            'short_description' => [
                'nullable',
                'string',
                'max:255',
            ],

            'description' => [
                'nullable',
                'string',
            ],

            'price' => [
                'required',
                'numeric',
                'min:0',
                'max:9999999999999.99',
            ],

            'discount_price' => [
                'nullable',
                'numeric',
                'min:0',
                'lte:price',
                'max:9999999999999.99',
            ],

            'stock' => [
                'required',
                'integer',
                'min:0',
                'max:4294967295',
            ],

            'status' => [
                'required',
                Rule::in([
                    'active',
                    'inactive',
                ]),
            ],
        ]);
    }
}