<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\Category;
use App\Models\CategoryAttribute;
use App\Models\ProductAttributeValue;
use App\Models\VariantValue;
use Illuminate\Http\RedirectResponse;
use Illuminate\Http\Request;
use Illuminate\Validation\Rule;
use Illuminate\View\View;

class AdminCategoryAttributeController extends Controller
{
    public function index(Category $category): View
    {
        $attributes = $category
            ->attributes()
            ->orderBy('sort_order')
            ->orderBy('name')
            ->get();

        return view(
            'admin.categories.attributes',
            compact(
                'category',
                'attributes'
            )
        );
    }

    public function store(
        Request $request,
        Category $category
    ): RedirectResponse {
        $validated = $request->validate([
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
                    'category_attributes',
                    'slug'
                )->where(
                    fn ($query) =>
                    $query->where(
                        'category_id',
                        $category->id
                    )
                ),
            ],

            'type' => [
                'required',
                Rule::in([
                    'text',
                    'number',
                    'boolean',
                ]),
            ],

            'sort_order' => [
                'required',
                'integer',
                'min:0',
            ],
        ]);

        $category->attributes()->create([
            'name' => $validated['name'],
            'slug' => $validated['slug'],
            'type' => $validated['type'],
            'is_required' =>
                $request->boolean('is_required'),
            'sort_order' =>
                $validated['sort_order'],
        ]);

        return back()->with(
            'success',
            'ویژگی دسته‌بندی ایجاد شد.'
        );
    }

    public function update(
        Request $request,
        Category $category,
        CategoryAttribute $attribute
    ): RedirectResponse {
        abort_unless(
            $attribute->category_id === $category->id,
            404
        );

        $validated = $request->validate([
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
                    'category_attributes',
                    'slug'
                )
                    ->where(
                        fn ($query) =>
                        $query->where(
                            'category_id',
                            $category->id
                        )
                    )
                    ->ignore($attribute->id),
            ],

            'type' => [
                'required',
                Rule::in([
                    'text',
                    'number',
                    'boolean',
                ]),
            ],

            'sort_order' => [
                'required',
                'integer',
                'min:0',
            ],
        ]);

        $attribute->update([
            'name' => $validated['name'],
            'slug' => $validated['slug'],
            'type' => $validated['type'],
            'is_required' =>
                $request->boolean('is_required'),
            'sort_order' =>
                $validated['sort_order'],
        ]);

        return back()->with(
            'success',
            'ویژگی دسته‌بندی ویرایش شد.'
        );
    }

    public function destroy(
        Category $category,
        CategoryAttribute $attribute
    ): RedirectResponse {
        abort_unless(
            $attribute->category_id === $category->id,
            404
        );

        $hasProductValues =
            ProductAttributeValue::where(
                'category_attribute_id',
                $attribute->id
            )->exists();

        $hasVariantValues =
            VariantValue::where(
                'category_attribute_id',
                $attribute->id
            )->exists();

        if (
            $hasProductValues ||
            $hasVariantValues
        ) {
            return back()->withErrors([
                'attribute' =>
                    'این ویژگی در محصول یا Variant استفاده شده و برای جلوگیری از حذف اطلاعات قابل حذف نیست.',
            ]);
        }

        $attribute->delete();

        return back()->with(
            'success',
            'ویژگی دسته‌بندی حذف شد.'
        );
    }
}