# E-Commerce Laravel Backend

این پوشه شامل REST API، سرویس‌های کسب‌وکار و پنل Blade مدیریت است.

## اجرای محلی

```bash
cp .env.example .env
composer install
php artisan key:generate
php artisan migrate:fresh --seed
php artisan storage:link
php artisan serve
```

برای ساخت فایل‌های CSS/JS پنل در صورت نیاز:

```bash
npm install
npm run build
```

## حساب‌های تست Seeder

| نقش | شماره | رمز |
|---|---|---|
| مدیر | `09120000001` | `password` |
| مشتری | `09120000002` | `password` |

Base URL API برابر `/api` است. تنظیمات ارسال و کد `WELCOME10` نیز همراه
با seed داده می‌شوند.

## پنل مدیریت

آدرس پنل `/admin/login` است. پنل به‌صورت Blade/HTML/CSS پیاده‌سازی شده و
بخش‌های دسته‌بندی، مشخصات، محصولات، تصاویر، تنوع‌ها، سفارش‌ها، کاربران،
نظرات، تخفیف‌ها، بنرها و تنظیمات ارسال را پوشش می‌دهد.
