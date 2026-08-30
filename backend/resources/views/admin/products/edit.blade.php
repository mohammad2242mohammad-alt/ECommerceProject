@extends('admin.layout')

@section('title', 'ویرایش محصول')

@section('content')

<div class="page-header">

    <h1>
        ویرایش محصول
    </h1>

    <a
        href="{{ route('admin.products.index') }}"
        class="btn btn-light"
    >
        بازگشت
    </a>

</div>

<div class="card">

    <form
        method="POST"
        action="{{ route('admin.products.update', $product) }}"
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
                    value="{{ old('name', $product->name) }}"
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
                    value="{{ old('slug', $product->slug) }}"
                    class="ltr"
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
                    value="{{ old('sku', $product->sku) }}"
                    class="ltr"
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
                    value="{{ old('price', $product->price) }}"
                    min="0"
                    step="0.01"
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
                    value="{{ old('discount_price', $product->discount_price) }}"
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
                    value="{{ old('stock', $product->stock) }}"
                    min="0"
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
            >{{ old('description', $product->description) }}</textarea>

        </div>

        <button
            type="submit"
            class="btn btn-primary"
        >
            ذخیره تغییرات
        </button>

    </form>

</div>

@endsection