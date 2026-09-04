<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\Category;
use Illuminate\Http\RedirectResponse;
use Illuminate\Http\Request;
use Illuminate\Validation\Rule;
use Illuminate\View\View;

class AdminCategoryController extends Controller
{
    public function index(): View
    {
        $categories = Category::query()
            ->with('parent')
            ->withCount([
                'products',
                'children',
            ])
            ->orderBy('sort_order')
            ->orderBy('name')
            ->get();

        return view(
            'admin.categories.index',
            compact('categories')
        );
    }

    public function create(): View
    {
        $parents = Category::query()
            ->whereNull('parent_id')
            ->orderBy('sort_order')
            ->orderBy('name')
            ->get();

        return view(
            'admin.categories.create',
            compact('parents')
        );
    }

    public function store(Request $request): RedirectResponse
    {
        $validated = $request->validate([
            'parent_id' => [
                'nullable',
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
                'unique:categories,slug',
            ],

            'description' => [
                'nullable',
                'string',
            ],

            'sort_order' => [
                'required',
                'integer',
                'min:0',
            ],

            'is_active' => [
                'required',
                'boolean',
            ],
        ]);

        Category::create([
            'parent_id' => $validated['parent_id'] ?? null,
            'name' => $validated['name'],
            'slug' => $validated['slug'],
            'description' => $validated['description'] ?? null,
            'image' => null,
            'sort_order' => $validated['sort_order'],
            'is_active' => $validated['is_active'],
        ]);

        return redirect()
            ->route('admin.categories.index')
            ->with(
                'success',
                'دسته‌بندی با موفقیت ایجاد شد.'
            );
    }

    public function edit(Category $category): View
    {
        $parents = Category::query()
            ->whereNull('parent_id')
            ->where('id', '!=', $category->id)
            ->orderBy('sort_order')
            ->orderBy('name')
            ->get();

        return view(
            'admin.categories.edit',
            compact(
                'category',
                'parents'
            )
        );
    }

    public function update(
        Request $request,
        Category $category
    ): RedirectResponse {
        $validated = $request->validate([
            'parent_id' => [
                'nullable',
                'integer',
                'exists:categories,id',
                Rule::notIn([$category->id]),
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
                    'categories',
                    'slug'
                )->ignore($category->id),
            ],

            'description' => [
                'nullable',
                'string',
            ],

            'sort_order' => [
                'required',
                'integer',
                'min:0',
            ],

            'is_active' => [
                'required',
                'boolean',
            ],
        ]);

        $category->update([
            'parent_id' => $validated['parent_id'] ?? null,
            'name' => $validated['name'],
            'slug' => $validated['slug'],
            'description' => $validated['description'] ?? null,
            'sort_order' => $validated['sort_order'],
            'is_active' => $validated['is_active'],
        ]);

        return redirect()
            ->route('admin.categories.index')
            ->with(
                'success',
                'دسته‌بندی با موفقیت ویرایش شد.'
            );
    }

    public function destroy(Category $category): RedirectResponse
    {
        if ($category->products()->exists()) {
            return back()
                ->withErrors([
                    'delete' =>
                        'این دسته‌بندی دارای محصول است و برای جلوگیری از حذف محصولات قابل حذف نیست.',
                ]);
        }

        if ($category->children()->exists()) {
            return back()
                ->withErrors([
                    'delete' =>
                        'این دسته‌بندی دارای زیر‌دسته است. ابتدا زیر‌دسته‌ها را منتقل یا حذف کنید.',
                ]);
        }

        $category->delete();

        return redirect()
            ->route('admin.categories.index')
            ->with(
                'success',
                'دسته‌بندی با موفقیت حذف شد.'
            );
    }

    public function toggle(Category $category): RedirectResponse
    {
        $category->update([
            'is_active' => !$category->is_active,
        ]);

        return back()
            ->with(
                'success',
                'وضعیت دسته‌بندی تغییر کرد.'
            );
    }
}