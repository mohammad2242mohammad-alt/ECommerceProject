<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\CategoryAttribute;
use App\Models\Product;
use App\Models\ProductVariant;
use App\Models\VariantValue;
use Illuminate\Http\RedirectResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;
use Illuminate\Validation\Rule;

class AdminProductVariantController extends Controller
{
    public function store(
        Request $request,
        Product $product
    ): RedirectResponse {
        $validated = $this->validateVariant(
            $request
        );

        DB::transaction(function () use (
            $request,
            $product,
            $validated
        ) {
            $variant = $product->variants()->create([
                'sku' => $validated['sku'] ?? null,
                'price' => $validated['price'] ?? null,
                'discount_price' =>
                    $validated['discount_price'] ?? null,
                'stock' => $validated['stock'],
                'is_active' =>
                    $request->boolean('is_active'),
                'status' =>
                    $request->boolean('is_active')
                        ? 'active'
                        : 'inactive',
            ]);

            $this->syncValues(
                $product,
                $variant,
                $request->input('values', [])
            );
        });

        return back()->with(
            'success',
            'تنوع محصول با موفقیت ایجاد شد.'
        );
    }

    public function update(
        Request $request,
        Product $product,
        ProductVariant $variant
    ): RedirectResponse {
        $this->ensureBelongsToProduct(
            $product,
            $variant
        );

        $validated = $this->validateVariant(
            $request,
            $variant
        );

        DB::transaction(function () use (
            $request,
            $product,
            $variant,
            $validated
        ) {
            $variant->update([
                'sku' => $validated['sku'] ?? null,
                'price' => $validated['price'] ?? null,
                'discount_price' =>
                    $validated['discount_price'] ?? null,
                'stock' => $validated['stock'],
                'is_active' =>
                    $request->boolean('is_active'),
                'status' =>
                    $request->boolean('is_active')
                        ? 'active'
                        : 'inactive',
            ]);

            $this->syncValues(
                $product,
                $variant,
                $request->input('values', [])
            );
        });

        return back()->with(
            'success',
            'تنوع محصول با موفقیت ویرایش شد.'
        );
    }

    public function destroy(
        Product $product,
        ProductVariant $variant
    ): RedirectResponse {
        $this->ensureBelongsToProduct(
            $product,
            $variant
        );

        $hasCartReference = false;
        $hasOrderReference = false;

        if (
            Schema::hasTable('cart_items') &&
            Schema::hasColumn(
                'cart_items',
                'product_variant_id'
            )
        ) {
            $hasCartReference =
                DB::table('cart_items')
                    ->where(
                        'product_variant_id',
                        $variant->id
                    )
                    ->exists();
        }

        if (
            Schema::hasTable('cart_items') &&
            Schema::hasColumn(
                'cart_items',
                'variant_id'
            )
        ) {
            $hasCartReference =
                $hasCartReference ||
                DB::table('cart_items')
                    ->where(
                        'variant_id',
                        $variant->id
                    )
                    ->exists();
        }

        if (
            Schema::hasTable('order_items') &&
            Schema::hasColumn(
                'order_items',
                'product_variant_id'
            )
        ) {
            $hasOrderReference =
                DB::table('order_items')
                    ->where(
                        'product_variant_id',
                        $variant->id
                    )
                    ->exists();
        }

        if (
            Schema::hasTable('order_items') &&
            Schema::hasColumn(
                'order_items',
                'variant_id'
            )
        ) {
            $hasOrderReference =
                $hasOrderReference ||
                DB::table('order_items')
                    ->where(
                        'variant_id',
                        $variant->id
                    )
                    ->exists();
        }

        if (
            $hasCartReference ||
            $hasOrderReference
        ) {
            return back()->withErrors([
                'variant' =>
                    'این تنوع دارای سابقه سبد خرید یا سفارش است و قابل حذف نیست. آن را غیرفعال کنید.',
            ]);
        }

        $variant->delete();

        return back()->with(
            'success',
            'تنوع محصول حذف شد.'
        );
    }

    private function validateVariant(
        Request $request,
        ?ProductVariant $variant = null
    ): array {
        return $request->validate([
            'sku' => [
                'nullable',
                'string',
                'max:255',

                Rule::unique(
                    'product_variants',
                    'sku'
                )->ignore(
                    $variant?->id
                ),
            ],

            'price' => [
                'nullable',
                'required_with:discount_price',
                'numeric',
                'min:0',
                'max:9999999999.99',
            ],

            'discount_price' => [
                'nullable',
                'numeric',
                'min:0',
                'lte:price',
                'max:9999999999.99',
            ],

            'stock' => [
                'required',
                'integer',
                'min:0',
                'max:2147483647',
            ],

            'values' => [
                'nullable',
                'array',
            ],

            'values.*' => [
                'nullable',
                'string',
                'max:255',
            ],
        ]);
    }

    private function syncValues(
        Product $product,
        ProductVariant $variant,
        array $values
    ): void {
        $attributes = CategoryAttribute::query()
            ->where(
                'category_id',
                $product->category_id
            )
            ->get();

        $allowedAttributeIds =
            $attributes->pluck('id');

        VariantValue::query()
            ->where(
                'product_variant_id',
                $variant->id
            )
            ->when(
                $allowedAttributeIds->isNotEmpty(),
                fn ($query) =>
                $query->whereNotIn(
                    'category_attribute_id',
                    $allowedAttributeIds
                ),
                fn ($query) =>
                $query
            )
            ->delete();

        foreach ($attributes as $attribute) {
            $value = isset(
                $values[$attribute->id]
            )
                ? trim(
                    (string)
                    $values[$attribute->id]
                )
                : '';

            if ($value === '') {
                VariantValue::query()
                    ->where(
                        'product_variant_id',
                        $variant->id
                    )
                    ->where(
                        'category_attribute_id',
                        $attribute->id
                    )
                    ->delete();

                continue;
            }

            VariantValue::updateOrCreate(
                [
                    'product_variant_id' =>
                        $variant->id,

                    'category_attribute_id' =>
                        $attribute->id,
                ],
                [
                    'value' => $value,
                ]
            );
        }
    }

    private function ensureBelongsToProduct(
        Product $product,
        ProductVariant $variant
    ): void {
        abort_unless(
            $variant->product_id === $product->id,
            404
        );
    }
}
