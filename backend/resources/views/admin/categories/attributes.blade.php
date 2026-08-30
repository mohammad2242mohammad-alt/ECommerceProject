@extends('admin.layout')

@section('title', 'ویژگی‌های دسته‌بندی')

@section('content')

<div class="page-header">

    <div>
        <h1>
            ویژگی‌های {{ $category->name }}
        </h1>

        <div class="muted">
            این ویژگی‌ها در مشخصات محصولات این دسته استفاده می‌شوند.
        </div>
    </div>

    <a
        href="{{ route('admin.categories.index') }}"
        class="btn btn-light"
    >
        بازگشت
    </a>

</div>

<div class="card">

    <h3>
        افزودن ویژگی جدید
    </h3>

    <form
        method="POST"
        action="{{ route(
            'admin.categories.attributes.store',
            $category
        ) }}"
    >

        @csrf

        <div class="form-grid">

            <div class="form-group">

                <label>نام ویژگی</label>

                <input
                    type="text"
                    name="name"
                    placeholder="مثلاً حافظه داخلی"
                    required
                >

            </div>

            <div class="form-group">

                <label>Slug</label>

                <input
                    type="text"
                    name="slug"
                    class="ltr"
                    placeholder="storage"
                    required
                >

            </div>

            <div class="form-group">

                <label>نوع</label>

                <select name="type">

                    <option value="text">
                        متن
                    </option>

                    <option value="number">
                        عدد
                    </option>

                    <option value="boolean">
                        بله / خیر
                    </option>

                </select>

            </div>

            <div class="form-group">

                <label>ترتیب</label>

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
                type="checkbox"
                id="is_required"
                name="is_required"
                value="1"
            >

            <label for="is_required">
                اجباری باشد
            </label>

        </div>

        <br>

        <button
            class="btn btn-primary"
            type="submit"
        >
            افزودن ویژگی
        </button>

    </form>

</div>

@foreach ($attributes as $attribute)

    <div class="card">

        <form
            method="POST"
            action="{{ route(
                'admin.categories.attributes.update',
                [
                    $category,
                    $attribute
                ]
            ) }}"
        >

            @csrf
            @method('PUT')

            <div class="form-grid">

                <div class="form-group">

                    <label>نام</label>

                    <input
                        name="name"
                        value="{{ $attribute->name }}"
                        required
                    >

                </div>

                <div class="form-group">

                    <label>Slug</label>

                    <input
                        name="slug"
                        class="ltr"
                        value="{{ $attribute->slug }}"
                        required
                    >

                </div>

                <div class="form-group">

                    <label>نوع</label>

                    <select name="type">

                        <option
                            value="text"
                            @selected(
                                $attribute->type === 'text'
                            )
                        >
                            متن
                        </option>

                        <option
                            value="number"
                            @selected(
                                $attribute->type === 'number'
                            )
                        >
                            عدد
                        </option>

                        <option
                            value="boolean"
                            @selected(
                                $attribute->type === 'boolean'
                            )
                        >
                            بله / خیر
                        </option>

                    </select>

                </div>

                <div class="form-group">

                    <label>ترتیب</label>

                    <input
                        type="number"
                        name="sort_order"
                        value="{{ $attribute->sort_order }}"
                        min="0"
                    >

                </div>

            </div>

            <div class="checkbox-row">

                <input
                    type="checkbox"
                    name="is_required"
                    value="1"
                    @checked($attribute->is_required)
                >

                <label>
                    اجباری
                </label>

            </div>

            <br>

            <button
                class="btn btn-primary"
                type="submit"
            >
                ذخیره تغییرات
            </button>

        </form>

        <br>

        <form
            method="POST"
            action="{{ route(
                'admin.categories.attributes.destroy',
                [
                    $category,
                    $attribute
                ]
            ) }}"
            onsubmit="return confirm('این ویژگی حذف شود؟')"
        >

            @csrf
            @method('DELETE')

            <button
                class="btn btn-danger"
                type="submit"
            >
                حذف ویژگی
            </button>

        </form>

    </div>

@endforeach

@endsection