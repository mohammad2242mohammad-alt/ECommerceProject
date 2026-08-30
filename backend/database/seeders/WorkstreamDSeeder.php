<?php

namespace Database\Seeders;

use App\Models\Category;
use App\Models\CategoryAttribute;
use App\Models\Product;
use App\Models\ProductAttributeValue;
use App\Models\ProductVariant;
use App\Models\VariantValue;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB;

class WorkstreamDSeeder extends Seeder
{
    public function run(): void
    {
        DB::transaction(function () {

            $categoriesData = [
                [
                    'code' => 'MOB',
                    'name' => 'موبایل',
                    'slug' => 'wsd-mobile-phones',
                    'base_price' => 18000000,
                    'items' => [
                        'گوشی Alpha X1',
                        'گوشی Alpha X2',
                        'گوشی Nova S1',
                        'گوشی Nova S2',
                        'گوشی Pixel Pro Test',
                    ],
                ],
                [
                    'code' => 'LAP',
                    'name' => 'لپ‌تاپ',
                    'slug' => 'wsd-laptops',
                    'base_price' => 35000000,
                    'items' => [
                        'لپ‌تاپ Vision 14',
                        'لپ‌تاپ Vision 15',
                        'لپ‌تاپ ProBook Test',
                        'لپ‌تاپ Creator X',
                        'لپ‌تاپ Gaming G1',
                    ],
                ],
                [
                    'code' => 'TAB',
                    'name' => 'تبلت',
                    'slug' => 'wsd-tablets',
                    'base_price' => 12000000,
                    'items' => [
                        'تبلت Tab One',
                        'تبلت Tab Plus',
                        'تبلت Study Pad',
                        'تبلت Media Pad',
                        'تبلت Pro Tab',
                    ],
                ],
                [
                    'code' => 'HDP',
                    'name' => 'هدفون',
                    'slug' => 'wsd-headphones',
                    'base_price' => 1800000,
                    'items' => [
                        'هدفون Air Sound',
                        'هدفون Bass Pro',
                        'هدفون Studio Test',
                        'هدفون Wireless One',
                        'هدفون Gaming Headset',
                    ],
                ],
                [
                    'code' => 'WAT',
                    'name' => 'ساعت هوشمند',
                    'slug' => 'wsd-smart-watches',
                    'base_price' => 4500000,
                    'items' => [
                        'ساعت Smart One',
                        'ساعت Fit Pro',
                        'ساعت Active Test',
                        'ساعت Sport X',
                        'ساعت Watch Mini',
                    ],
                ],
                [
                    'code' => 'ACC',
                    'name' => 'لوازم جانبی',
                    'slug' => 'wsd-accessories',
                    'base_price' => 500000,
                    'items' => [
                        'شارژر سریع',
                        'کابل Type C',
                        'پاوربانک تست',
                        'هاب USB',
                        'پایه نگهدارنده',
                    ],
                ],
                [
                    'code' => 'MON',
                    'name' => 'مانیتور',
                    'slug' => 'wsd-monitors',
                    'base_price' => 9000000,
                    'items' => [
                        'مانیتور Vision 24',
                        'مانیتور Vision 27',
                        'مانیتور Gaming 27',
                        'مانیتور Creator 32',
                        'مانیتور Office Test',
                    ],
                ],
                [
                    'code' => 'CON',
                    'name' => 'کنسول بازی',
                    'slug' => 'wsd-gaming-consoles',
                    'base_price' => 22000000,
                    'items' => [
                        'کنسول Game One',
                        'کنسول Game Pro',
                        'کنسول Game Mini',
                        'کنسول Portable Test',
                        'کنسول Retro Box',
                    ],
                ],
                [
                    'code' => 'CAM',
                    'name' => 'دوربین',
                    'slug' => 'wsd-cameras',
                    'base_price' => 28000000,
                    'items' => [
                        'دوربین Camera One',
                        'دوربین Creator Cam',
                        'دوربین Vlog Test',
                        'دوربین Compact X',
                        'دوربین Pro Camera',
                    ],
                ],
                [
                    'code' => 'SMH',
                    'name' => 'خانه هوشمند',
                    'slug' => 'wsd-smart-home',
                    'base_price' => 2500000,
                    'items' => [
                        'لامپ هوشمند',
                        'پریز هوشمند',
                        'دوربین خانه هوشمند',
                        'هاب خانه هوشمند',
                        'سنسور هوشمند',
                    ],
                ],
            ];

            $categoryMap = [];

            foreach (
                $categoriesData as $categoryIndex => $categoryData
            ) {
                $category = Category::updateOrCreate(
                    [
                        'slug' => $categoryData['slug'],
                    ],
                    [
                        'parent_id' => null,
                        'name' => $categoryData['name'],
                        'description' =>
                            'دسته‌بندی تستی Workstream D',
                        'image' => null,
                        'sort_order' => $categoryIndex + 20,
                        'is_active' => true,
                    ]
                );

                $categoryMap[
                    $categoryData['slug']
                ] = $category;

                foreach (
                    $categoryData['items'] as $index => $productName
                ) {
                    $number = $index + 1;

                    $price =
                        $categoryData['base_price']
                        + ($number * 350000);

                    $discountPrice =
                        $number % 2 === 0
                            ? $price - 250000
                            : null;

                    Product::updateOrCreate(
                        [
                            'slug' =>
                                $categoryData['slug']
                                .'-product-'
                                .$number,
                        ],
                        [
                            'category_id' =>
                                $category->id,

                            'name' =>
                                $productName,

                            'sku' =>
                                'WSD-'
                                .$categoryData['code']
                                .'-'
                                .str_pad(
                                    (string) $number,
                                    3,
                                    '0',
                                    STR_PAD_LEFT
                                ),

                            'short_description' =>
                                'محصول تستی برای پنل مدیریت فروشگاه',

                            'description' =>
                                'این محصول به‌صورت خودکار توسط WorkstreamDSeeder برای تست پنل مدیریت، API و جریان فروشگاه ایجاد شده است.',

                            'price' =>
                                $price,

                            'discount_price' =>
                                $discountPrice,

                            'stock' =>
                                10 + ($number * 3),

                            'status' =>
                                'active',
                        ]
                    );
                }
            }

            $this->seedMobileData(
                $categoryMap['wsd-mobile-phones']
            );

            $this->seedLaptopData(
                $categoryMap['wsd-laptops']
            );
        });
    }

    private function seedMobileData(
        Category $category
    ): void {
        $storage = $this->attribute(
            $category,
            'حافظه داخلی',
            'storage',
            'text',
            true,
            1
        );

        $ram = $this->attribute(
            $category,
            'رم',
            'ram',
            'text',
            true,
            2
        );

        $dualSim = $this->attribute(
            $category,
            'دو سیم‌کارت',
            'dual-sim',
            'boolean',
            false,
            3
        );

        $color = $this->attribute(
            $category,
            'رنگ',
            'color',
            'text',
            false,
            4
        );

        $product = Product::where(
            'sku',
            'WSD-MOB-001'
        )->firstOrFail();

        $this->productValue(
            $product,
            $storage,
            '256GB'
        );

        $this->productValue(
            $product,
            $ram,
            '8GB'
        );

        $this->productValue(
            $product,
            $dualSim,
            '1'
        );

        $this->productValue(
            $product,
            $color,
            'مشکی'
        );

        $variant1 = ProductVariant::updateOrCreate(
            [
                'sku' => 'WSD-MOB-001-256-BLK',
            ],
            [
                'product_id' => $product->id,
                'price' => 19500000,
                'discount_price' => 18900000,
                'stock' => 12,
                'is_active' => true,
            ]
        );

        $this->variantValue(
            $variant1,
            $storage,
            '256GB'
        );

        $this->variantValue(
            $variant1,
            $ram,
            '8GB'
        );

        $this->variantValue(
            $variant1,
            $dualSim,
            '1'
        );

        $this->variantValue(
            $variant1,
            $color,
            'مشکی'
        );

        $variant2 = ProductVariant::updateOrCreate(
            [
                'sku' => 'WSD-MOB-001-128-BLU',
            ],
            [
                'product_id' => $product->id,
                'price' => 18200000,
                'discount_price' => null,
                'stock' => 8,
                'is_active' => true,
            ]
        );

        $this->variantValue(
            $variant2,
            $storage,
            '128GB'
        );

        $this->variantValue(
            $variant2,
            $ram,
            '6GB'
        );

        $this->variantValue(
            $variant2,
            $dualSim,
            '1'
        );

        $this->variantValue(
            $variant2,
            $color,
            'آبی'
        );
    }

    private function seedLaptopData(
        Category $category
    ): void {
        $ram = $this->attribute(
            $category,
            'رم',
            'ram',
            'text',
            true,
            1
        );

        $storage = $this->attribute(
            $category,
            'حافظه',
            'storage',
            'text',
            true,
            2
        );

        $screen = $this->attribute(
            $category,
            'اندازه صفحه',
            'screen-size',
            'text',
            false,
            3
        );

        $product = Product::where(
            'sku',
            'WSD-LAP-001'
        )->firstOrFail();

        $this->productValue(
            $product,
            $ram,
            '16GB'
        );

        $this->productValue(
            $product,
            $storage,
            '512GB SSD'
        );

        $this->productValue(
            $product,
            $screen,
            '14 inch'
        );

        $variant = ProductVariant::updateOrCreate(
            [
                'sku' => 'WSD-LAP-001-16-512',
            ],
            [
                'product_id' => $product->id,
                'price' => 36500000,
                'discount_price' => 35900000,
                'stock' => 6,
                'is_active' => true,
            ]
        );

        $this->variantValue(
            $variant,
            $ram,
            '16GB'
        );

        $this->variantValue(
            $variant,
            $storage,
            '512GB SSD'
        );

        $this->variantValue(
            $variant,
            $screen,
            '14 inch'
        );
    }

    private function attribute(
        Category $category,
        string $name,
        string $slug,
        string $type,
        bool $required,
        int $sortOrder
    ): CategoryAttribute {
        return CategoryAttribute::updateOrCreate(
            [
                'category_id' => $category->id,
                'slug' => $slug,
            ],
            [
                'name' => $name,
                'type' => $type,
                'is_required' => $required,
                'sort_order' => $sortOrder,
            ]
        );
    }

    private function productValue(
        Product $product,
        CategoryAttribute $attribute,
        string $value
    ): void {
        ProductAttributeValue::updateOrCreate(
            [
                'product_id' => $product->id,
                'category_attribute_id' =>
                    $attribute->id,
            ],
            [
                'value' => $value,
            ]
        );
    }

    private function variantValue(
        ProductVariant $variant,
        CategoryAttribute $attribute,
        string $value
    ): void {
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