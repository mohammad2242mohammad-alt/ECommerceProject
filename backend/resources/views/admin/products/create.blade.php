@extends('admin.layout')

@section('title', 'افزودن محصول')

@section('content')

<div class="page-header">

    <h1>
        افزودن محصول
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
        action="{{ route('admin.products.store') }}"
    >

        @csrf

        <div class="form-grid">

            <div class="form-group">

                <label>
                    نام محصول
                </label>

                <input
                    type="text"
                    name="name"
                    value="{{ old('name') }}"
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

                    <option value="">
                        انتخاب کنید
                    </option>

                    @foreach ($categories as $category)

                        <option
                            value="{{ $category->id }}"
                            @selected(
                                old('category_id') == $category->id
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
                    value="{{ old('slug') }}"
                    placeholder="iphone-17"
                    class="ltr"
                    required
                >

                <div class="hint">
                    فقط حروف انگلیسی کوچک، عدد و خط تیره
                </div>

            </div>

            <div class="form-group">

                <label>
                    SKU
                </label>

                <input
                    type="text"
                    name="sku"
                    value="{{ old('sku') }}"
                    placeholder="IPH17-001"
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
                    value="{{ old('price') }}"
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
                    value="{{ old('discount_price') }}"
                    min="0"
                    step="0.01"
                >

                <div class="hint">
                    در صورت نداشتن تخفیف خالی بگذارید.
                </div>

            </div>

            <div class="form-group">

                <label>
                    موجودی
                </label>

                <input
                    type="number"
                    name="stock"
                    value="{{ old('stock', 0) }}"
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
                        @selected(old('status', 'active') === 'active')
                    >
                        فعال
                    </option>

                    <option
                        value="inactive"
                        @selected(old('status') === 'inactive')
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
                value="{{ old('short_description') }}"
                maxlength="255"
            >

        </div>

        <div class="form-group">

            <label>
                توضیحات کامل
            </label>

            <textarea
                name="description"
            >{{ old('description') }}</textarea>

        </div>

        <button
            type="submit"
            class="btn btn-primary"
        >
            ذخیره محصول
        </button>

    </form>

</div>

@endsection