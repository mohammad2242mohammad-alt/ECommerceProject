@extends('admin.layout')

@section('title', 'داشبورد مدیریت')

@section('content')

<h1>
    داشبورد
</h1>

<div class="stats-grid">

    <div class="card">
        محصولات

        <div class="number">
            {{ $stats['products'] }}
        </div>
    </div>

    <div class="card">
        دسته‌بندی‌ها

        <div class="number">
            {{ $stats['categories'] }}
        </div>
    </div>

    <div class="card">
        سفارش‌ها

        <div class="number">
            {{ $stats['orders'] }}
        </div>
    </div>

    <div class="card">
        کاربران

        <div class="number">
            {{ $stats['customers'] }}
        </div>
    </div>

    <div class="card">
        بنرها

        <div class="number">
            {{ $stats['banners'] }}
        </div>
    </div>

    <div class="card">
        کدهای تخفیف

        <div class="number">
            {{ $stats['coupons'] }}
        </div>
    </div>

</div>

@endsection
