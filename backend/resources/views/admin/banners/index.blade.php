@extends('admin.layout')

@section('title', 'مدیریت بنرها')

@section('content')

<div class="page-header">
    <h1>بنرها</h1>

    <a href="{{ route('admin.banners.create') }}" class="btn btn-primary">
        + افزودن بنر
    </a>
</div>

<div class="card">
    <table>
        <thead>
        <tr>
            <th>تصویر</th>
            <th>عنوان</th>
            <th>لینک</th>
            <th>ترتیب</th>
            <th>وضعیت</th>
            <th>عملیات</th>
        </tr>
        </thead>
        <tbody>
        @forelse ($banners as $banner)
            <tr>
                <td class="ltr">{{ $banner->image }}</td>
                <td><strong>{{ $banner->title }}</strong></td>
                <td>{{ $banner->link_type ? $banner->link_type.': '.$banner->link_value : '—' }}</td>
                <td>{{ $banner->sort_order }}</td>
                <td>
                    @if ($banner->is_active)
                        <span class="badge badge-active">فعال</span>
                    @else
                        <span class="badge badge-inactive">غیرفعال</span>
                    @endif
                </td>
                <td>
                    <div class="actions">
                        <a href="{{ route('admin.banners.edit', $banner) }}" class="btn btn-light">ویرایش</a>
                        <form method="POST" action="{{ route('admin.banners.toggle', $banner) }}">
                            @csrf
                            <button type="submit" class="btn btn-success">تغییر وضعیت</button>
                        </form>
                        <form method="POST" action="{{ route('admin.banners.destroy', $banner) }}" onsubmit="return confirm('از حذف این بنر مطمئن هستید؟')">
                            @csrf
                            @method('DELETE')
                            <button type="submit" class="btn btn-danger">حذف</button>
                        </form>
                    </div>
                </td>
            </tr>
        @empty
            <tr><td colspan="6">هنوز بنری ثبت نشده است.</td></tr>
        @endforelse
        </tbody>
    </table>
</div>

{{ $banners->links() }}

@endsection
