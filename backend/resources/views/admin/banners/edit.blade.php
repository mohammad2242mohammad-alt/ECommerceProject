@extends('admin.layout')

@section('title', 'ویرایش بنر')

@section('content')

<div class="page-header">
    <h1>ویرایش بنر</h1>
    <a href="{{ route('admin.banners.index') }}" class="btn btn-light">بازگشت</a>
</div>

<div class="card">
    <form method="POST" action="{{ route('admin.banners.update', $banner) }}" enctype="multipart/form-data">
        @csrf
        @method('PUT')

        <div class="form-grid">
            <div class="form-group">
                <label>عنوان</label>
                <input type="text" name="title" value="{{ old('title', $banner->title) }}" required>
            </div>

            <div class="form-group">
                <label>مسیر تصویر یا URL</label>
                <input type="text" name="image" value="{{ old('image', $banner->image) }}">
            </div>

            <div class="form-group">
                <label>جایگزینی تصویر</label>
                <input type="file" name="image_file" accept=".jpg,.jpeg,.png,.webp">
            </div>

            <div class="form-group">
                <label>نوع لینک</label>
                <input type="text" name="link_type" value="{{ old('link_type', $banner->link_type) }}">
            </div>

            <div class="form-group">
                <label>مقدار لینک</label>
                <input type="text" name="link_value" value="{{ old('link_value', $banner->link_value) }}">
            </div>

            <div class="form-group">
                <label>ترتیب نمایش</label>
                <input type="number" name="sort_order" value="{{ old('sort_order', $banner->sort_order) }}" min="0">
            </div>

            <div class="form-group">
                <label>شروع نمایش</label>
                <input type="datetime-local" name="starts_at" value="{{ old('starts_at', optional($banner->starts_at)->format('Y-m-d\\TH:i')) }}">
            </div>

            <div class="form-group">
                <label>پایان نمایش</label>
                <input type="datetime-local" name="ends_at" value="{{ old('ends_at', optional($banner->ends_at)->format('Y-m-d\\TH:i')) }}">
            </div>
        </div>

        <div class="checkbox-row form-group">
            <input id="banner_active" type="checkbox" name="is_active" value="1" @checked(old('is_active', $banner->is_active))>
            <label for="banner_active">فعال باشد</label>
        </div>

        <button type="submit" class="btn btn-primary">ذخیره تغییرات</button>
    </form>
</div>

@endsection
