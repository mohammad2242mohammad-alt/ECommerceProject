<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;
use Illuminate\Support\Facades\Storage;

class ProductDetailResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [

            'id' => $this->id,

            'name' => $this->name,

            'slug' => $this->slug,

            'sku' => $this->sku,

            'short_description' => $this->short_description,

            'description' => $this->description,

            'price' => $this->money($this->price),

            'discount_price' => $this->money($this->discount_price),

            'stock' => $this->stock,

            'status' => $this->status,

            'rating_average' => $this->rating_average,

            'rating_count' => $this->rating_count,


            'category' => [
                'id' => $this->category?->id,
                'name' => $this->category?->name,
            ],


            'images' => $this->images->map(function ($image) {

                return [
                    'id' => $image->id,
                    'url' => Storage::url($image->path),
                    'is_primary' => $image->is_primary,
                ];

            }),


            'specifications' => $this->attributeValues->map(function ($item) {

                return [
                    'name' => $item->attribute?->name,
                    'value' => $item->value,
                ];

            }),


            'variants' => $this->variants->map(function ($variant) {

                return [

                    'id' => $variant->id,

                    'sku' => $variant->sku,

                    'price' => $this->money($variant->price),

                    'discount_price' => $this->money($variant->discount_price),

                    'stock' => $variant->stock,

                    'status' => $variant->status,
                    'is_active' => $variant->is_active,


                    'values' => $variant->values->map(function ($value) {

                        return [
                            'name' => $value->attribute?->name,
                            'value' => $value->value,
                        ];

                    }),

                ];

            }),

        ];
    }

    private function money(mixed $value): int|float|null
    {
        if ($value === null) {
            return null;
        }

        $number = (float) $value;

        return fmod($number, 1.0) === 0.0
            ? (int) $number
            : $number;
    }
}
