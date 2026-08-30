<!DOCTYPE html>
<html lang="fa" dir="rtl">

<head>

    <meta charset="UTF-8">

    <meta
        name="viewport"
        content="width=device-width, initial-scale=1.0"
    >

    <title>
        @yield('title', 'پنل مدیریت')
    </title>

    <style>
        * {
            box-sizing: border-box;
        }

        body {
            margin: 0;
            background: #f5f6f8;
            color: #262626;
            font-family: Tahoma, Arial, sans-serif;
        }

        a {
            text-decoration: none;
            color: inherit;
        }

        .sidebar {
            position: fixed;
            right: 0;
            top: 0;
            bottom: 0;
            width: 240px;
            padding: 25px 16px;
            background: #ffffff;
            border-left: 1px solid #e7e7e7;
            overflow-y: auto;
        }

        .brand {
            font-size: 22px;
            font-weight: bold;
            margin-bottom: 30px;
        }

        .brand span {
            color: #ef4056;
        }

        .nav-item {
            display: block;
            padding: 12px 14px;
            margin-bottom: 7px;
            border-radius: 10px;
            color: #555;
        }

        .nav-item:hover,
        .nav-item.active {
            color: #ef4056;
            background: #fff0f2;
        }

        .nav-disabled {
            color: #aaa;
            cursor: default;
        }

        .nav-disabled:hover {
            color: #aaa;
            background: transparent;
        }

        .content {
            margin-right: 240px;
            min-height: 100vh;
        }

        .topbar {
            height: 70px;
            padding: 0 28px;
            background: white;
            border-bottom: 1px solid #e7e7e7;
            display: flex;
            align-items: center;
            justify-content: space-between;
        }

        .main {
            padding: 28px;
        }

        .logout {
            border: 0;
            background: transparent;
            color: #ef4056;
            cursor: pointer;
            font-family: inherit;
        }

        .page-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            gap: 16px;
            margin-bottom: 22px;
        }

        .page-header h1 {
            margin: 0;
            font-size: 24px;
        }

        .stats-grid {
            display: grid;
            grid-template-columns:
                repeat(4, minmax(0, 1fr));
            gap: 16px;
        }

        .card {
            background: white;
            border-radius: 14px;
            border: 1px solid #ececec;
            padding: 20px;
            margin-bottom: 20px;
        }

        .number {
            margin-top: 10px;
            font-size: 30px;
            font-weight: bold;
        }

        .btn {
            display: inline-block;
            border: 0;
            border-radius: 9px;
            padding: 10px 15px;
            cursor: pointer;
            font-family: inherit;
            font-size: 13px;
        }

        .btn-primary {
            background: #ef4056;
            color: white;
        }

        .btn-light {
            background: #f1f1f1;
            color: #333;
        }

        .btn-success {
            background: #e8f7ef;
            color: #16834b;
        }

        .btn-danger {
            background: #fff0f2;
            color: #c6283d;
        }

        table {
            width: 100%;
            border-collapse: collapse;
        }

        th,
        td {
            padding: 13px 10px;
            border-bottom: 1px solid #eeeeee;
            text-align: right;
            vertical-align: middle;
        }

        th {
            color: #777;
            font-size: 13px;
            font-weight: normal;
        }

        tbody tr:last-child td {
            border-bottom: 0;
        }

        .badge {
            display: inline-block;
            border-radius: 999px;
            padding: 6px 10px;
            font-size: 12px;
        }

        .badge-active {
            background: #e8f7ef;
            color: #16834b;
        }

        .badge-inactive {
            background: #eeeeee;
            color: #777;
        }

        .actions {
            display: flex;
            align-items: center;
            gap: 7px;
            flex-wrap: wrap;
        }

        .actions form {
            margin: 0;
        }

        .alert {
            border-radius: 10px;
            padding: 13px 15px;
            margin-bottom: 20px;
        }

        .alert-success {
            background: #e8f7ef;
            color: #166534;
        }

        .alert-danger {
            background: #fff0f2;
            color: #b42336;
        }

        .alert ul {
            margin: 0;
            padding-right: 20px;
        }

        .form-group {
            margin-bottom: 18px;
        }

        .form-grid {
            display: grid;
            grid-template-columns:
                repeat(2, minmax(0, 1fr));
            gap: 18px;
        }

        .filters-grid {
            display: grid;
            grid-template-columns:
                2fr 1fr 1fr auto;
            gap: 10px;
            align-items: end;
        }

        label {
            display: block;
            margin-bottom: 7px;
            font-size: 14px;
        }

        input,
        select,
        textarea {
            width: 100%;
            padding: 11px 12px;
            border: 1px solid #dddddd;
            border-radius: 9px;
            background: white;
            font-family: inherit;
            outline: none;
        }

        input:focus,
        select:focus,
        textarea:focus {
            border-color: #ef4056;
        }

        textarea {
            min-height: 120px;
            resize: vertical;
        }

        .checkbox-row {
            display: flex;
            align-items: center;
            gap: 8px;
        }

        .checkbox-row input {
            width: auto;
        }

        .checkbox-row label {
            margin: 0;
        }

        .hint {
            color: #888;
            font-size: 12px;
            margin-top: 6px;
        }

        .muted {
            color: #888;
            font-size: 13px;
        }

        .ltr {
            direction: ltr;
            text-align: left;
        }

        @media (max-width: 900px) {

            .sidebar {
                width: 190px;
            }

            .content {
                margin-right: 190px;
            }

            .stats-grid,
            .form-grid {
                grid-template-columns:
                    repeat(2, minmax(0, 1fr));
            }

            .filters-grid {
                grid-template-columns: 1fr;
            }
        }

    </style>

</head>

<body>

<aside class="sidebar">

    <div class="brand">
        پنل <span>مدیریت</span>
    </div>

    <a
        href="{{ route('admin.dashboard') }}"
        class="nav-item
        {{ request()->routeIs('admin.dashboard') ? 'active' : '' }}"
    >
        داشبورد
    </a>

    <a
        href="{{ route('admin.categories.index') }}"
        class="nav-item
        {{ request()->routeIs('admin.categories.*') ? 'active' : '' }}"
    >
        دسته‌بندی‌ها
    </a>

    <a
        href="{{ route('admin.products.index') }}"
        class="nav-item
        {{ request()->routeIs('admin.products.*') ? 'active' : '' }}"
    >
        محصولات
    </a>

    <div class="nav-item nav-disabled">
        سفارش‌ها
    </div>

    <div class="nav-item nav-disabled">
        نظرات
    </div>

    <div class="nav-item nav-disabled">
        کدهای تخفیف
    </div>

</aside>

<div class="content">

    <header class="topbar">

        <div>
            {{ auth()->user()->name ?? 'مدیر سیستم' }}
        </div>

        <form
            method="POST"
            action="{{ route('admin.logout') }}"
        >
            @csrf

            <button
                type="submit"
                class="logout"
            >
                خروج
            </button>

        </form>

    </header>

    <main class="main">

        @if (session('success'))
            <div class="alert alert-success">
                {{ session('success') }}
            </div>
        @endif

        @if ($errors->any())

            <div class="alert alert-danger">

                <ul>

                    @foreach ($errors->all() as $error)

                        <li>
                            {{ $error }}
                        </li>

                    @endforeach

                </ul>

            </div>

        @endif

        @yield('content')

    </main>

</div>

</body>
</html>