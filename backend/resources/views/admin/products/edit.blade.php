@extends('admin.layout')

@section('title', 'ویرایش محصول')

@section('content')

<div class="page-header">

    <div>
        <h1>
            {{ $product->name }}
        </h1>

        <div class="muted">
            مدیریت اطلاعات، تصاویر، مشخصات و تنوع‌های محصول
        </div>
    </div>

    <a
        href="{{ route('admin.products.index') }}"
        class="btn btn-light"
    >
        بازگشت
    </a>

</div>


{{-- اطلاعات اصلی محصول --}}
<div class="card">

    <h3>
        اطلاعات اصلی محصول
    </h3>

    <form
        method="POST"
        action="{{ route(
            'admin.products.update',
            $product
        ) }}"
    >

        @csrf
        @method('PUT')

        <div class="form-grid">

            <div class="form-group">

                <label>
                    نام محصول
                </label>

                <input
                    type="text"
                    name="name"
                    value="{{ old(
                        'name',
                        $product->name
                    ) }}"
                    required
                >

            </div>

            <div class="form-group">

                <label>
                    دسته‌بندی
                </label>

                <select
                    name="category_id"
                    required
                >

                    @foreach ($categories as $category)

                        <option
                            value="{{ $category->id }}"
                            @selected(
                                old(
                                    'category_id',
                                    $product->category_id
                                ) == $category->id
                            )
                        >
                            {{ $category->name }}
                        </option>

                    @endforeach

                </select>

            </div>

            <div class="form-group">

                <label>
                    Slug
                </label>

                <input
                    type="text"
                    name="slug"
                    class="ltr"
                    value="{{ old(
                        'slug',
                        $product->slug
                    ) }}"
                    required
                >

            </div>

            <div class="form-group">

                <label>
                    SKU
                </label>

                <input
                    type="text"
                    name="sku"
                    class="ltr"
                    value="{{ old(
                        'sku',
                        $product->sku
                    ) }}"
                    required
                >

            </div>

            <div class="form-group">

                <label>
                    قیمت
                </label>

                <input
                    type="number"
                    name="price"
                    step="0.01"
                    min="0"
                    value="{{ old(
                        'price',
                        $product->price
                    ) }}"
                    required
                >

            </div>

            <div class="form-group">

                <label>
                    قیمت تخفیف‌خورده
                </label>

                <input
                    type="number"
                    name="discount_price"
                    step="0.01"
                    min="0"
                    value="{{ old(
                        'discount_price',
                        $product->discount_price
                    ) }}"
                >

            </div>

            <div class="form-group">

                <label>
                    موجودی
                </label>

                <input
                    type="number"
                    name="stock"
                    min="0"
                    value="{{ old(
                        'stock',
                        $product->stock
                    ) }}"
                    required
                >

            </div>

            <div class="form-group">

                <label>
                    وضعیت
                </label>

                <select
                    name="status"
                    required
                >

                    <option
                        value="active"
                        @selected(
                            old(
                                'status',
                                $product->status
                            ) === 'active'
                        )
                    >
                        فعال
                    </option>

                    <option
                        value="inactive"
                        @selected(
                            old(
                                'status',
                                $product->status
                            ) === 'inactive'
                        )
                    >
                        غیرفعال
                    </option>

                </select>

            </div>

        </div>

        <div class="form-group">

            <label>
                توضیح کوتاه
            </label>

            <input
                type="text"
                name="short_description"
                maxlength="255"
                value="{{ old(
                    'short_description',
                    $product->short_description
                ) }}"
            >

        </div>

        <div class="form-group">

            <label>
                توضیحات کامل
            </label>

            <textarea
                name="description"
            >{{ old(
                'description',
                $product->description
            ) }}</textarea>

        </div>

        <button
            class="btn btn-primary"
            type="submit"
        >
            ذخیره اطلاعات اصلی
        </button>

    </form>

</div>


{{-- تصاویر محصول --}}
<div class="card">

    <h3>
        تصاویر محصول
    </h3>

    <p class="muted">
        تصویر جدید اضافه کنید و تصویر اصلی محصول را مشخص کنید.
    </p>

    <form
        method="POST"
        enctype="multipart/form-data"
        action="{{ route(
            'admin.products.images.store',
            $product
        ) }}"
    >

        @csrf

        <div class="form-grid">

            <div class="form-group">

                <label>
                    انتخاب تصویر
                </label>

                <input
                    type="file"
                    name="image"
                    accept=".jpg,.jpeg,.png,.webp"
                    required
                >

                <div class="hint">
                    JPG، PNG یا WEBP حداکثر 4MB
                </div>

            </div>

            <div class="form-group">

                <label>
                    متن جایگزین تصویر
                </label>

                <input
                    type="text"
                    name="alt_text"
                    placeholder="مثلاً نمای جلوی محصول"
                >

            </div>

            <div class="form-group">

                <label>
                    ترتیب نمایش
                </label>

                <input
                    type="number"
                    name="sort_order"
                    value="0"
                    min="0"
                    required
                >

            </div>

        </div>

        <div class="checkbox-row">

            <input
                id="image_primary"
                type="checkbox"
                name="is_primary"
                value="1"
            >

            <label for="image_primary">
                این تصویر اصلی محصول باشد
            </label>

        </div>

        <br>

        <button
            class="btn btn-primary"
            type="submit"
        >
            آپلود تصویر
        </button>

    </form>


    @if ($product->images->count())

        <hr
            style="
                border:0;
                border-top:1px solid #eee;
                margin:25px 0;
            "
        >

        <div
            style="
                display:grid;
                grid-template-columns:
                    repeat(auto-fill, minmax(190px, 1fr));
                gap:16px;
            "
        >

            @foreach ($product->images as $image)

                <div
                    style="
                        border:1px solid #eee;
                        border-radius:12px;
                        padding:12px;
                        background:#fff;
                    "
                >

                    <img
                        src="{{ asset(
                            'storage/'.$image->path
                        ) }}"
                        alt="{{ $image->alt_text }}"
                        style="
                            width:100%;
                            height:160px;
                            object-fit:cover;
                            border-radius:9px;
                            margin-bottom:12px;
                        "
                    >

                    <div class="muted">
                        ترتیب: {{ $image->sort_order }}
                    </div>

                    <br>

                    @if ($image->is_primary)

                        <span class="badge badge-active">
                            تصویر اصلی
                        </span>

                    @else

                        <form
                            method="POST"
                            action="{{ route(
                                'admin.products.images.primary',
                                [
                                    $product,
                                    $image
                                ]
                            ) }}"
                        >

                            @csrf

                            <button
                                class="btn btn-light"
                                type="submit"
                            >
                                انتخاب به‌عنوان تصویر اصلی
                            </button>

                        </form>

                    @endif

                    <br>

                    <form
                        method="POST"
                        action="{{ route(
                            'admin.products.images.destroy',
                            [
                                $product,
                                $image
                            ]
                        ) }}"
                        onsubmit="return confirm('این تصویر حذف شود؟')"
                    >

                        @csrf
                        @method('DELETE')

                        <button
                            class="btn btn-danger"
                            type="submit"
                        >
                            حذف تصویر
                        </button>

                    </form>

                </div>

            @endforeach

        </div>

    @else

        <div
            style="
                margin-top:20px;
                padding:18px;
                border-radius:10px;
                background:#f8f8f8;
                color:#888;
            "
        >
            هنوز تصویری برای این محصول ثبت نشده است.
        </div>

    @endif

</div>


{{-- مشخصات محصول --}}
<div class="card">

    <h3>
        مشخصات محصول
    </h3>

    <p class="muted">
        مشخصات بر اساس ویژگی‌های تعریف‌شده برای دسته‌بندی محصول نمایش داده می‌شوند.
    </p>

    @if ($categoryAttributes->isEmpty())

        <div
            style="
                padding:18px;
                border-radius:10px;
                background:#f8f8f8;
                margin-bottom:16px;
            "
        >
            برای دسته‌بندی این محصول هنوز ویژگی‌ای تعریف نشده است.
        </div>

        <a
            href="{{ route(
                'admin.categories.attributes.index',
                $product->category_id
            ) }}"
            class="btn btn-primary"
        >
            تعریف ویژگی‌های دسته‌بندی
        </a>

    @else

        <form
            method="POST"
            action="{{ route(
                'admin.products.attributes.update',
                $product
            ) }}"
        >

            @csrf

            <div class="form-grid">

                @foreach ($categoryAttributes as $attribute)

                    @php
                        $currentValue =
                            $attributeValueMap
                                ->get($attribute->id)
                                ?->value;
                    @endphp

                    <div class="form-group">

                        <label>

                            {{ $attribute->name }}

                            @if ($attribute->is_required)
                                <span style="color:#ef4056;">
                                    *
                                </span>
                            @endif

                        </label>

                        @if ($attribute->type === 'boolean')

                            <select
                                name="values[{{ $attribute->id }}]"
                                @required($attribute->is_required)
                            >

                                <option value="">
                                    انتخاب کنید
                                </option>

                                <option
                                    value="1"
                                    @selected(
                                        old(
                                            'values.'.$attribute->id,
                                            $currentValue
                                        ) === '1'
                                    )
                                >
                                    بله
                                </option>

                                <option
                                    value="0"
                                    @selected(
                                        old(
                                            'values.'.$attribute->id,
                                            $currentValue
                                        ) === '0'
                                    )
                                >
                                    خیر
                                </option>

                            </select>

                        @else

                            <input
                                type="{{ $attribute->type === 'number' ? 'number' : 'text' }}"
                                name="values[{{ $attribute->id }}]"
                                value="{{ old(
                                    'values.'.$attribute->id,
                                    $currentValue
                                ) }}"
                                @required($attribute->is_required)
                            >

                        @endif

                    </div>

                @endforeach

            </div>

            <button
                class="btn btn-primary"
                type="submit"
            >
                ذخیره مشخصات محصول
            </button>

        </form>

    @endif

</div>


{{-- افزودن Variant --}}
<div class="card">

    <h3>
        تنوع‌های محصول
    </h3>

    <p class="muted">
        برای حالت‌های مختلف محصول مانند حافظه، رم، رنگ یا سایر ویژگی‌ها تنوع ایجاد کنید.
    </p>

    <h4>
        افزودن تنوع جدید
    </h4>

    <form
        method="POST"
        action="{{ route(
            'admin.products.variants.store',
            $product
        ) }}"
    >

        @csrf

        <div class="form-grid">

            <div class="form-group">

                <label>
                    SKU تنوع
                </label>

                <input
                    type="text"
                    name="sku"
                    class="ltr"
                    placeholder="VARIANT-001"
                >

            </div>

            <div class="form-group">

                <label>
                    قیمت اختصاصی
                </label>

                <input
                    type="number"
                    name="price"
                    min="0"
                    step="0.01"
                >

                <div class="hint">
                    در صورت خالی بودن، قیمت پایه محصول مبنا خواهد بود.
                </div>

            </div>

            <div class="form-group">

                <label>
                    قیمت تخفیف‌خورده
                </label>

                <input
                    type="number"
                    name="discount_price"
                    min="0"
                    step="0.01"
                >

            </div>

            <div class="form-group">

                <label>
                    موجودی
                </label>

                <input
                    type="number"
                    name="stock"
                    min="0"
                    value="0"
                    required
                >

            </div>

        </div>

        @if ($categoryAttributes->count())

            <h4>
                مقادیر ویژگی‌های تنوع
            </h4>

            <div class="form-grid">

                @foreach ($categoryAttributes as $attribute)

                    <div class="form-group">

                        <label>
                            {{ $attribute->name }}
                        </label>

                        @if ($attribute->type === 'boolean')

                            <select
                                name="values[{{ $attribute->id }}]"
                            >

                                <option value="">
                                    انتخاب نشده
                                </option>

                                <option value="1">
                                    بله
                                </option>

                                <option value="0">
                                    خیر
                                </option>

                            </select>

                        @else

                            <input
                                type="{{ $attribute->type === 'number' ? 'number' : 'text' }}"
                                name="values[{{ $attribute->id }}]"
                            >

                        @endif

                    </div>

                @endforeach

            </div>

        @endif

        <input
            type="hidden"
            name="is_active"
            value="0"
        >

        <div class="checkbox-row">

            <input
                id="new_variant_active"
                type="checkbox"
                name="is_active"
                value="1"
                checked
            >

            <label for="new_variant_active">
                تنوع فعال باشد
            </label>

        </div>

        <br>

        <button
            class="btn btn-primary"
            type="submit"
        >
            افزودن تنوع
        </button>

    </form>

</div>


{{-- Variantهای موجود --}}
@forelse ($product->variants as $variant)

    @php
        $variantValueMap =
            $variant
                ->values
                ->keyBy(
                    'category_attribute_id'
                );
    @endphp

    <div class="card">

        <div class="page-header">

            <div>

                <h3 style="margin:0 0 6px 0;">
                    تنوع #{{ $variant->id }}
                </h3>

                <div class="muted">
                    {{ $variant->sku ?? 'بدون SKU' }}
                </div>

            </div>

            @if ($variant->is_active)

                <span class="badge badge-active">
                    فعال
                </span>

            @else

                <span class="badge badge-inactive">
                    غیرفعال
                </span>

            @endif

        </div>

        <form
            method="POST"
            action="{{ route(
                'admin.products.variants.update',
                [
                    $product,
                    $variant
                ]
            ) }}"
        >

            @csrf
            @method('PUT')

            <div class="form-grid">

                <div class="form-group">

                    <label>
                        SKU
                    </label>

                    <input
                        type="text"
                        name="sku"
                        class="ltr"
                        value="{{ $variant->sku }}"
                    >

                </div>

                <div class="form-group">

                    <label>
                        قیمت اختصاصی
                    </label>

                    <input
                        type="number"
                        name="price"
                        min="0"
                        step="0.01"
                        value="{{ $variant->price }}"
                    >

                </div>

                <div class="form-group">

                    <label>
                        قیمت تخفیف‌خورده
                    </label>

                    <input
                        type="number"
                        name="discount_price"
                        min="0"
                        step="0.01"
                        value="{{ $variant->discount_price }}"
                    >

                </div>

                <div class="form-group">

                    <label>
                        موجودی
                    </label>

                    <input
                        type="number"
                        name="stock"
                        min="0"
                        value="{{ $variant->stock }}"
                        required
                    >

                </div>

            </div>

            @if ($categoryAttributes->count())

                <div class="form-grid">

                    @foreach ($categoryAttributes as $attribute)

                        @php
                            $variantValue =
                                $variantValueMap
                                    ->get(
                                        $attribute->id
                                    )
                                    ?->value;
                        @endphp

                        <div class="form-group">

                            <label>
                                {{ $attribute->name }}
                            </label>

                            @if ($attribute->type === 'boolean')

                                <select
                                    name="values[{{ $attribute->id }}]"
                                >

                                    <option value="">
                                        انتخاب نشده
                                    </option>

                                    <option
                                        value="1"
                                        @selected(
                                            $variantValue === '1'
                                        )
                                    >
                                        بله
                                    </option>

                                    <option
                                        value="0"
                                        @selected(
                                            $variantValue === '0'
                                        )
                                    >
                                        خیر
                                    </option>

                                </select>

                            @else

                                <input
                                    type="{{ $attribute->type === 'number' ? 'number' : 'text' }}"
                                    name="values[{{ $attribute->id }}]"
                                    value="{{ $variantValue }}"
                                >

                            @endif

                        </div>

                    @endforeach

                </div>

            @endif

            <input
                type="hidden"
                name="is_active"
                value="0"
            >

            <div class="checkbox-row">

                <input
                    id="variant_active_{{ $variant->id }}"
                    type="checkbox"
                    name="is_active"
                    value="1"
                    @checked(
                        $variant->is_active
                    )
                >

                <label
                    for="variant_active_{{ $variant->id }}"
                >
                    این تنوع فعال باشد
                </label>

            </div>

            <br>

            <button
                class="btn btn-primary"
                type="submit"
            >
                ذخیره تغییرات تنوع
            </button>

        </form>

        <br>

        <form
            method="POST"
            action="{{ route(
                'admin.products.variants.destroy',
                [
                    $product,
                    $variant
                ]
            ) }}"
            onsubmit="return confirm('این تنوع حذف شود؟')"
        >

            @csrf
            @method('DELETE')

            <button
                class="btn btn-danger"
                type="submit"
            >
                حذف تنوع
            </button>

        </form>

    </div>

@empty

    <div class="card">

        <div class="muted">
            هنوز هیچ تنوعی برای این محصول تعریف نشده است.
        </div>

    </div>

@endforelse

@endsection