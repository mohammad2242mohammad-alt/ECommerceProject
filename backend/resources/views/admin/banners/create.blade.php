@extends('admin.layout')

@section('title', 'افزودن بنر')

@section('content')

<div class="page-header">
    <h1>افزودن بنر</h1>
    <a href="{{ route('admin.banners.index') }}" class="btn btn-light">بازگشت</a>
</div>

<div class="card">
    <form method="POST" action="{{ route('admin.banners.store') }}" enctype="multipart/form-data">
        @csrf

        <div class="form-grid">
            <div class="form-group">
                <label>عنوان</label>
                <input type="text" name="title" value="{{ old('title') }}" required>
            </div>

            <div class="form-group">
                <label>مسیر تصویر یا URL</label>
                <input type="text" name="image" value="{{ old('image') }}" placeholder="banners/summer.jpg">
                <div class="hint">یا از فایل زیر استفاده کنید.</div>
            </div>

            <div class="form-group">
                <label>آپلود تصویر</label>
                <input type="file" name="image_file" accept=".jpg,.jpeg,.png,.webp">
            </div>

            <div class="form-group">
                <label>نوع لینک</label>
                <input type="text" name="link_type" value="{{ old('link_type') }}" placeholder="product یا category">
            </div>

            <div class="form-group">
                <label>مقدار لینک</label>
                <input type="text" name="link_value" value="{{ old('link_value') }}">
            </div>

            <div class="form-group">
                <label>ترتیب نمایش</label>
                <input type="number" name="sort_order" value="{{ old('sort_order', 0) }}" min="0">
            </div>

            <div class="form-group">
                <label>شروع نمایش</label>
                <input type="datetime-local" name="starts_at" value="{{ old('starts_at') }}">
            </div>

            <div class="form-group">
                <label>پایان نمایش</label>
                <input type="datetime-local" name="ends_at" value="{{ old('ends_at') }}">
            </div>
        </div>

        <div class="checkbox-row form-group">
            <input id="banner_active" type="checkbox" name="is_active" value="1" @checked(old('is_active', true))>
            <label for="banner_active">فعال باشد</label>
        </div>

        <button type="submit" class="btn btn-primary">ذخیره بنر</button>
    </form>
</div>

@endsection
