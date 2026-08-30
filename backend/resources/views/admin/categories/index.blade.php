@extends('admin.layout')

@section('title', 'مدیریت دسته‌بندی‌ها')

@section('content')

<div class="page-header">

    <h1>
        دسته‌بندی‌ها
    </h1>

    <a
        href="{{ route('admin.categories.create') }}"
        class="btn btn-primary"
    >
        + افزودن دسته‌بندی
    </a>

</div>

<div class="card">

    <table>

        <thead>

        <tr>
            <th>نام</th>
            <th>والد</th>
            <th>محصول</th>
            <th>زیر‌دسته</th>
            <th>ترتیب</th>
            <th>وضعیت</th>
            <th>عملیات</th>
        </tr>

        </thead>

        <tbody>

        @forelse ($categories as $category)

            <tr>

                <td>
                    <strong>
                        {{ $category->name }}
                    </strong>
                </td>

                <td>
                    {{ $category->parent?->name ?? '—' }}
                </td>

                <td>
                    {{ $category->products_count }}
                </td>

                <td>
                    {{ $category->children_count }}
                </td>

                <td>
                    {{ $category->sort_order }}
                </td>

                <td>

                    @if ($category->is_active)

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
                            href="{{ route('admin.categories.edit', $category) }}"
                            class="btn btn-light"
                        >
                            ویرایش
                        </a>

                        <form
                            method="POST"
                            action="{{ route('admin.categories.toggle', $category) }}"
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
                            action="{{ route('admin.categories.destroy', $category) }}"
                            onsubmit="return confirm('از حذف این دسته‌بندی مطمئن هستید؟')"
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

                <td colspan="7">
                    هنوز دسته‌بندی‌ای ثبت نشده است.
                </td>

            </tr>

        @endforelse

        </tbody>

    </table>

</div>

@endsection