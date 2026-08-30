@extends('admin.layout')

@section('title', 'ویرایش محصول')

@section('content')

<div class="page-header">

    <div>

        <h1>
            {{ $product->name }}
        </h1>

        <div class="muted">
            مدیریت اطلاعات، تصاویر و مشخصات محصول
        </div>

    </div>

    <a
        href="{{ route('admin.products.index') }}"
        class="btn btn-light"
    >
        بازگشت
    </a>

</div>

<div class="card">

    <h3>
        اطلاعات اصلی
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

                <label>نام محصول</label>

                <input
                    name="name"
                    value="{{ old(
                        'name',
                        $product->name
                    ) }}"
                    required
                >

            </div>

            <div class="form-group">

                <label>دسته‌بندی</label>

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

                <label>Slug</label>

                <input
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

                <label>SKU</label>

                <input
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

                <label>قیمت</label>

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

                <label>موجودی</label>

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

                <label>وضعیت</label>

                <select name="status">

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

            <label>توضیح کوتاه</label>

            <input
                name="short_description"
                value="{{ old(
                    'short_description',
                    $product->short_description
                ) }}"
            >

        </div>

        <div class="form-group">

            <label>توضیحات کامل</label>

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


<div class="card">

    <h3>
        تصاویر محصول
    </h3>

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

                <label>تصویر</label>

                <input
                    type="file"
                    name="image"
                    accept=".jpg,.jpeg,.png,.webp"
                    required
                >

            </div>

            <div class="form-group">

                <label>متن Alt</label>

                <input
                    name="alt_text"
                    placeholder="توضیح تصویر"
                >

            </div>

            <div class="form-group">

                <label>ترتیب نمایش</label>

                <input
                    type="number"
                    name="sort_order"
                    value="0"
                    min="0"
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
                تصویر اصلی باشد
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

        <hr style="border:0;border-top:1px solid #eee;margin:25px 0;">

        <div
            style="
                display:grid;
                grid-template-columns:repeat(
                    auto-fill,
                    minmax(180px,1fr)
                );
                gap:16px;
            "
        >

            @foreach ($product->images as $image)

                <div
                    style="
                        border:1px solid #eee;
                        border-radius:12px;
                        padding:12px;
                    "
                >

                    <img
                        src="{{ asset(
                            'storage/'.$image->path
                        ) }}"
                        alt="{{ $image->alt_text }}"
                        style="
                            width:100%;
                            height:150px;
                            object-fit:cover;
                            border-radius:8px;
                            margin-bottom:10px;
                        "
                    >

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
                                انتخاب به‌عنوان اصلی
                            </button>

                        </form>

                    @endif

                    <br><br>

                    <form
                        method="POST"
                        action="{{ route(
                            'admin.products.images.destroy',
                            [
                                $product,
                                $image
                            ]
                        ) }}"
                        onsubmit="return confirm('تصویر حذف شود؟')"
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

    @endif

</div>


<div class="card">

    <h3>
        مشخصات محصول
    </h3>

    @if ($categoryAttributes->isEmpty())

        <p class="muted">
            برای دسته‌بندی این محصول هنوز ویژگی‌ای تعریف نشده است.
        </p>

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

            @foreach ($categoryAttributes as $attribute)

                <div class="form-group">

                    <label>

                        {{ $attribute->name }}

                        @if ($attribute->is_required)
                            *
                        @endif

                    </label>

                    @php
                        $currentValue =
                            $attributeValueMap
                            ->get($attribute->id)
                            ?->value;
                    @endphp

                    @if ($attribute->type === 'boolean')

                        <select
                            name="values[{{ $attribute->id }}]"
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

            <button
                class="btn btn-primary"
                type="submit"
            >
                ذخیره مشخصات
            </button>

        </form>

    @endif

</div>

@endsection