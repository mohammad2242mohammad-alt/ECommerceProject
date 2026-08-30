<!DOCTYPE html>
<html lang="fa" dir="rtl">

<head>
    <meta charset="UTF-8">

    <meta
        name="viewport"
        content="width=device-width, initial-scale=1.0"
    >

    <title>ورود مدیر</title>

    <style>
        * {
            box-sizing: border-box;
        }

        body {
            margin: 0;
            min-height: 100vh;
            display: flex;
            justify-content: center;
            align-items: center;
            background: #f5f6f8;
            font-family: Tahoma, Arial, sans-serif;
            color: #262626;
        }

        .login-box {
            width: 390px;
            background: #ffffff;
            padding: 34px;
            border-radius: 18px;
            border: 1px solid #e8e8e8;
        }

        .logo {
            font-size: 25px;
            font-weight: bold;
            margin-bottom: 8px;
        }

        .logo span {
            color: #ef4056;
        }

        .subtitle {
            color: #777;
            margin-bottom: 28px;
        }

        .form-group {
            margin-bottom: 18px;
        }

        label {
            display: block;
            margin-bottom: 7px;
            font-size: 14px;
        }

        input {
            width: 100%;
            padding: 12px;
            border: 1px solid #ddd;
            border-radius: 9px;
            font-family: inherit;
            outline: none;
        }

        input:focus {
            border-color: #ef4056;
        }

        button {
            width: 100%;
            padding: 12px;
            border: 0;
            border-radius: 9px;
            background: #ef4056;
            color: white;
            cursor: pointer;
            font-family: inherit;
            font-size: 15px;
        }

        .errors {
            background: #fff0f2;
            color: #b42336;
            border-radius: 9px;
            padding: 12px;
            margin-bottom: 18px;
        }
    </style>
</head>

<body>

<div class="login-box">

    <div class="logo">
        پنل <span>مدیریت</span>
    </div>

    <div class="subtitle">
        برای مدیریت فروشگاه وارد شوید
    </div>

    @if ($errors->any())
        <div class="errors">
            @foreach ($errors->all() as $error)
                <div>
                    {{ $error }}
                </div>
            @endforeach
        </div>
    @endif

    <form
        method="POST"
        action="{{ route('admin.login.submit') }}"
    >
        @csrf

        <div class="form-group">

            <label>
                شماره موبایل
            </label>

            <input
                type="text"
                name="phone"
                value="{{ old('phone') }}"
                maxlength="11"
                placeholder="09xxxxxxxxx"
                required
            >

        </div>

        <div class="form-group">

            <label>
                رمز عبور
            </label>

            <input
                type="password"
                name="password"
                required
            >

        </div>

        <button type="submit">
            ورود به پنل مدیریت
        </button>

    </form>

</div>

</body>
</html>