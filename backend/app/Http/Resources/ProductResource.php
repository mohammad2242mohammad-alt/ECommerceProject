<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;
use Illuminate\Support\Facades\Storage;

class ProductResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'category_id' => $this->category_id,
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

            'image' => $this->whenLoaded('images', function () {
                $image = $this->images->firstWhere('is_primary', true)
                    ?? $this->images->sortBy('sort_order')->first();

                return $image ? Storage::url($image->path) : null;
            }),

            'category' => $this->whenLoaded(
                'category',
                fn () => new CategoryResource($this->category)
            ),

            'created_at' => $this->created_at,
            'updated_at' => $this->updated_at,
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
