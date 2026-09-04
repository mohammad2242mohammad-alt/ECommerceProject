@extends('admin.layout')

@section('title', 'افزودن دسته‌بندی')

@section('content')

<div class="page-header">

    <h1>
        افزودن دسته‌بندی
    </h1>

    <a
        href="{{ route('admin.categories.index') }}"
        class="btn btn-light"
    >
        بازگشت
    </a>

</div>

<div class="card">

    <form
        method="POST"
        action="{{ route('admin.categories.store') }}"
    >

        @csrf

        <div class="form-group">

            <label>
                نام دسته‌بندی
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
                Slug
            </label>

            <input
                type="text"
                name="slug"
                value="{{ old('slug') }}"
                placeholder="example-category"
                dir="ltr"
                required
            >

            <div class="hint">
                فقط حروف انگلیسی کوچک، عدد و خط تیره
            </div>

        </div>

        <div class="form-group">

            <label>
                دسته والد
            </label>

            <select name="parent_id">

                <option value="">
                    بدون والد
                </option>

                @foreach ($parents as $parent)

                    <option
                        value="{{ $parent->id }}"
                        @selected(
                            old('parent_id') == $parent->id
                        )
                    >
                        {{ $parent->name }}
                    </option>

                @endforeach

            </select>

        </div>

        <div class="form-group">

            <label>
                توضیحات
            </label>

            <textarea
                name="description"
            >{{ old('description') }}</textarea>

        </div>

        <div class="form-group">

            <label>
                ترتیب نمایش
            </label>

            <input
                type="number"
                name="sort_order"
                min="0"
                value="{{ old('sort_order', 0) }}"
                required
            >

        </div>

        <div class="form-group">

            <input
                type="hidden"
                name="is_active"
                value="0"
            >

            <div class="checkbox-row">

                <input
                    id="is_active"
                    type="checkbox"
                    name="is_active"
                    value="1"
                    @checked(old('is_active', '1') == '1')
                >

                <label for="is_active">
                    دسته‌بندی فعال باشد
                </label>

            </div>

        </div>

        <button
            type="submit"
            class="btn btn-primary"
        >
            ذخیره دسته‌بندی
        </button>

    </form>

</div>

@endsection