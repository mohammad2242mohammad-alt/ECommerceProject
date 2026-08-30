<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\Category;
use App\Models\Product;
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
            $search = trim($request->string('search'));

            $query->where(function ($query) use ($search) {
                $query
                    ->where('name', 'like', "%{$search}%")
                    ->orWhere('sku', 'like', "%{$search}%")
                    ->orWhere('slug', 'like', "%{$search}%");
            });
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
                $request->string('status')
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

    public function store(Request $request): RedirectResponse
    {
        $validated = $request->validate([
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
                'unique:products,slug',
            ],

            'sku' => [
                'required',
                'string',
                'max:255',
                'unique:products,sku',
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
            ],

            'discount_price' => [
                'nullable',
                'numeric',
                'min:0',
                'lte:price',
            ],

            'stock' => [
                'required',
                'integer',
                'min:0',
            ],

            'status' => [
                'required',
                Rule::in([
                    'active',
                    'inactive',
                ]),
            ],
        ]);

        Product::create($validated);

        return redirect()
            ->route('admin.products.index')
            ->with(
                'success',
                'محصول با موفقیت ایجاد شد.'
            );
    }

    public function edit(Product $product): View
    {
        $categories = Category::query()
            ->orderBy('name')
            ->get();

        return view(
            'admin.products.edit',
            compact(
                'product',
                'categories'
            )
        );
    }

    public function update(
        Request $request,
        Product $product
    ): RedirectResponse {
        $validated = $request->validate([
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
                )->ignore($product->id),
            ],

            'sku' => [
                'required',
                'string',
                'max:255',
                Rule::unique(
                    'products',
                    'sku'
                )->ignore($product->id),
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
            ],

            'discount_price' => [
                'nullable',
                'numeric',
                'min:0',
                'lte:price',
            ],

            'stock' => [
                'required',
                'integer',
                'min:0',
            ],

            'status' => [
                'required',
                Rule::in([
                    'active',
                    'inactive',
                ]),
            ],
        ]);

        $product->update($validated);

        return redirect()
            ->route('admin.products.index')
            ->with(
                'success',
                'محصول با موفقیت ویرایش شد.'
            );
    }

    public function toggle(Product $product): RedirectResponse
    {
        $product->update([
            'status' => $product->status === 'active'
                ? 'inactive'
                : 'active',
        ]);

        return back()->with(
            'success',
            'وضعیت محصول تغییر کرد.'
        );
    }

    public function destroy(Product $product): RedirectResponse
    {
        $hasOrders = DB::table('order_items')
            ->where('product_id', $product->id)
            ->exists();

        $hasCartItems = DB::table('cart_items')
            ->where('product_id', $product->id)
            ->exists();

        $hasFavorites = DB::table('favorites')
            ->where('product_id', $product->id)
            ->exists();

        $hasReviews = DB::table('reviews')
            ->where('product_id', $product->id)
            ->exists();

        if (
            $hasOrders ||
            $hasCartItems ||
            $hasFavorites ||
            $hasReviews
        ) {
            return back()->withErrors([
                'delete' =>
                    'این محصول دارای سابقه سفارش، سبد خرید، علاقه‌مندی یا نظر است و برای حفظ اطلاعات قابل حذف نیست. می‌توانید آن را غیرفعال کنید.',
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
}