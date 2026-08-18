<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class CategoryResource extends JsonResource
{
    /**
     * تبدیل اطلاعات مدل دسته‌بندی به ساختار استاندارد مناسب برای API
     */
    public function toArray(Request $request): array
    {
        return [
            // شناسه یکتای دسته‌بندی
            'id' => $this->id,

            // شناسه دسته والد؛ برای دسته‌های اصلی مقدار آن null است
            'parent_id' => $this->parent_id,

            // نام دسته‌بندی
            'name' => $this->name,

            // نام یکتا برای استفاده در URL و جست‌وجو
            'slug' => $this->slug,

            // توضیح کوتاه دسته‌بندی
            'description' => $this->description,

            // مسیر تصویر دسته‌بندی؛ فعلاً ممکن است null باشد
            'image' => $this->image,

            // ترتیب نمایش دسته‌بندی در منو و لیست‌ها
            'sort_order' => $this->sort_order,

            // وضعیت فعال بودن دسته‌بندی
            'is_active' => $this->is_active,

            // زیردسته‌ها فقط زمانی نمایش داده می‌شوند که رابطه children بارگذاری شده باشد
            'children' => CategoryResource::collection($this->whenLoaded('children')),
        ];
    }
}