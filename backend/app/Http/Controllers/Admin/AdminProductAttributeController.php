<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\CategoryAttribute;
use App\Models\Product;
use App\Models\ProductAttributeValue;
use Illuminate\Http\RedirectResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class AdminProductAttributeController extends Controller
{
    public function update(
        Request $request,
        Product $product
    ): RedirectResponse {
        $attributes = CategoryAttribute::query()
            ->where(
                'category_id',
                $product->category_id
            )
            ->orderBy('sort_order')
            ->get();

        $rules = [
            'values' => [
                'nullable',
                'array',
            ],
        ];

        foreach ($attributes as $attribute) {
            $field =
                'values.'.$attribute->id;

            $rules[$field] = [
                $attribute->is_required
                    ? 'required'
                    : 'nullable',
                'string',
                'max:2000',
            ];
        }

        $validated = $request->validate(
            $rules
        );

        $values = $validated['values'] ?? [];

        DB::transaction(
            function () use (
                $product,
                $attributes,
                $values
            ) {
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
                        ProductAttributeValue::query()
                            ->where(
                                'product_id',
                                $product->id
                            )
                            ->where(
                                'category_attribute_id',
                                $attribute->id
                            )
                            ->delete();

                        continue;
                    }

                    ProductAttributeValue::updateOrCreate(
                        [
                            'product_id' =>
                                $product->id,

                            'category_attribute_id' =>
                                $attribute->id,
                        ],
                        [
                            'value' => $value,
                        ]
                    );
                }
            }
        );

        return back()->with(
            'success',
            'مشخصات محصول ذخیره شد.'
        );
    }
}