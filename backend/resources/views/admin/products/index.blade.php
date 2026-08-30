@extends('admin.layout')

@section('title', 'مدیریت محصولات')

@section('content')

<div class="page-header">

    <h1>
        محصولات
    </h1>

    <a
        href="{{ route('admin.products.create') }}"
        class="btn btn-primary"
    >
        + افزودن محصول
    </a>

</div>

<div class="card">

    <form
        method="GET"
        action="{{ route('admin.products.index') }}"
    >

        <div class="filters-grid">

            <div class="form-group">

                <label>
                    جستجو
                </label>

                <input
                    type="text"
                    name="search"
                    value="{{ request('search') }}"
                    placeholder="نام، SKU یا Slug"
                >

            </div>

            <div class="form-group">

                <label>
                    دسته‌بندی
                </label>

                <select name="category_id">

                    <option value="">
                        همه
                    </option>

                    @foreach ($categories as $category)

                        <option
                            value="{{ $category->id }}"
                            @selected(
                                request('category_id') == $category->id
                            )
                        >
                            {{ $category->name }}
                        </option>

                    @endforeach

                </select>

            </div>

            <div class="form-group">

                <label>
                    وضعیت
                </label>

                <select name="status">

                    <option value="">
                        همه
                    </option>

                    <option
                        value="active"
                        @selected(request('status') === 'active')
                    >
                        فعال
                    </option>

                    <option
                        value="inactive"
                        @selected(request('status') === 'inactive')
                    >
                        غیرفعال
                    </option>

                </select>

            </div>

            <div class="form-group">

                <button
                    type="submit"
                    class="btn btn-primary"
                >
                    فیلتر
                </button>

            </div>

        </div>

    </form>

</div>

<div class="card">

    <table>

        <thead>

        <tr>
            <th>ID</th>
            <th>نام</th>
            <th>SKU</th>
            <th>دسته</th>
            <th>قیمت</th>
            <th>تخفیف</th>
            <th>موجودی</th>
            <th>وضعیت</th>
            <th>عملیات</th>
        </tr>

        </thead>

        <tbody>

        @forelse ($products as $product)

            <tr>

                <td>
                    {{ $product->id }}
                </td>

                <td>
                    <strong>
                        {{ $product->name }}
                    </strong>

                    <div class="muted">
                        {{ $product->slug }}
                    </div>
                </td>

                <td class="ltr">
                    {{ $product->sku }}
                </td>

                <td>
                    {{ $product->category?->name ?? '—' }}
                </td>

                <td>
                    {{ number_format((float) $product->price) }}
                </td>

                <td>
                    @if ($product->discount_price)
                        {{ number_format((float) $product->discount_price) }}
                    @else
                        —
                    @endif
                </td>

                <td>
                    {{ number_format($product->stock) }}
                </td>

                <td>

                    @if ($product->status === 'active')

                        <span class="badge badge-active">
                            فعال
                        </span>

                    @else

                        <span class="badge badge-inactive">
                            غیرفعال
                        </span>

                    @endif

                </td>

                <td>

                    <div class="actions">

                        <a
                            href="{{ route('admin.products.edit', $product) }}"
                            class="btn btn-light"
                        >
                            ویرایش
                        </a>

                        <form
                            method="POST"
                            action="{{ route('admin.products.toggle', $product) }}"
                        >
                            @csrf

                            <button
                                type="submit"
                                class="btn btn-success"
                            >
                                تغییر وضعیت
                            </button>

                        </form>

                        <form
                            method="POST"
                            action="{{ route('admin.products.destroy', $product) }}"
                            onsubmit="return confirm('از حذف این محصول مطمئن هستید؟')"
                        >

                            @csrf
                            @method('DELETE')

                            <button
                                type="submit"
                                class="btn btn-danger"
                            >
                                حذف
                            </button>

                        </form>

                    </div>

                </td>

            </tr>

        @empty

            <tr>
                <td colspan="9">
                    محصولی پیدا نشد.
                </td>
            </tr>

        @endforelse

        </tbody>

    </table>

</div>

{{ $products->links() }}

@endsection