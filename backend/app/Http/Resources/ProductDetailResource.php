<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class ProductDetailResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [

            'id' => $this->id,

            'name' => $this->name,

            'slug' => $this->slug,

            'sku' => $this->sku,

            'description' => $this->description,

            'price' => $this->price,

            'discount_price' => $this->discount_price,

            'stock' => $this->stock,


            'category' => [
                'id' => $this->category->id,
                'name' => $this->category->name,
            ],


            'images' => $this->images->map(function ($image) {

                return [
                    'id' => $image->id,
                    'url' => \Storage::url($image->path),
                    'is_primary' => $image->is_primary,
                ];

            }),


            'specifications' => $this->attributeValues->map(function ($item) {

                return [
                    'name' => $item->attribute->name,
                    'value' => $item->value,
                ];

            }),


            'variants' => $this->variants->map(function ($variant) {

                return [

                    'id' => $variant->id,

                    'sku' => $variant->sku,

                    'price' => $variant->price,

                    'discount_price' => $variant->discount_price,

                    'stock' => $variant->stock,

                    'is_active' => $variant->is_active,


                    'values' => $variant->values->map(function ($value) {

                        return [
                            'name' => $value->attribute->name,
                            'value' => $value->value,
                        ];

                    }),

                ];

            }),

        ];
    }
}