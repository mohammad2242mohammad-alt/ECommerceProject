# E-Commerce Backend API

Laravel REST API backend for the E-Commerce project.

## Stack

* Laravel 13
* PHP 8.5+
* MySQL
* Laravel Sanctum
* REST API

## Setup

```bash
composer install
cp .env.example .env
php artisan key:generate
```

Configure the MySQL credentials in `.env`, then run:

```bash
php artisan migrate
php artisan storage:link
php artisan serve
```

Local API URL:

```text
http://127.0.0.1:8000/api
```

## Authentication

```text
POST /api/auth/register
POST /api/auth/login
GET  /api/auth/me
POST /api/auth/logout
```

Protected endpoints use:

```text
Authorization: Bearer TOKEN
```

## Categories

```text
GET /api/categories
GET /api/categories/{id}
GET /api/categories/{categoryId}/attributes
```

## Products

```text
GET /api/products
GET /api/products/{id}

GET /api/products/{productId}/attributes
GET /api/products/{productId}/images
GET /api/products/{productId}/variants
GET /api/variants/{variantId}/values
```

Product list supports:

```text
category_id
search
min_price
max_price
page
per_page
sort
```

Sort values:

```text
newest
oldest
price_asc
price_desc
rating_desc
```

## Cart

```text
GET    /api/cart?session_id=SESSION_ID
POST   /api/cart/items
PUT    /api/cart/items/{id}
DELETE /api/cart/items/{id}
```

Cart validation includes:

* Session ownership
* Product validation
* Variant validation
* Stock validation
* Server-side price calculation

## Addresses

Authentication required.

```text
GET    /api/addresses
POST   /api/addresses
GET    /api/addresses/{id}
PUT    /api/addresses/{id}
DELETE /api/addresses/{id}
```

## Coupons

```text
POST /api/coupons/validate
```

## Checkout

```text
POST /api/checkout/calculate
```

Backend calculates subtotal, discount, shipping and final total.

## Orders

Authentication required.

```text
GET  /api/orders
POST /api/orders
GET  /api/orders/{id}
POST /api/orders/{id}/cancel
```

Order creation includes:

* Cart validation
* Address ownership validation
* Stock validation
* Server-side pricing
* Order/product snapshots
* Stock decrement
* Coupon usage
* Cart clearing

Cancellation restores stock when applicable.

## Payments

Authentication required.

```text
POST /api/payments/{orderId}/start
GET  /api/payments/{orderId}/status
```

The development environment currently uses a mock payment gateway.

## Favorites

Authentication required.

```text
GET    /api/favorites
POST   /api/favorites
DELETE /api/favorites/{productId}
```

## Reviews

```text
GET  /api/products/{productId}/reviews
POST /api/products/{productId}/reviews
```

Review submission requires authentication and a delivered order containing the product.

New reviews are created as `pending`.

## Banners

```text
GET /api/banners
```

## Settings

```text
GET /api/settings
```

## Admin Security

Administrative write endpoints use Sanctum authentication and admin authorization.

Expected responses:

```text
Unauthenticated -> 401
Customer        -> 403
Authorized admin -> Allowed
Not found       -> 404
Validation      -> 422
```

## Security

Implemented protections include:

* Laravel Sanctum
* Admin middleware
* Address ownership validation
* Order ownership validation
* Payment ownership validation
* Cart session ownership validation
* Server-side prices
* Stock validation
* JSON authentication and authorization errors
* Database transactions
* Composer dependency audit

## Performance

Indexes are included for commonly queried fields.

Products:

```text
status + created_at
status + price
status + rating_average
category_id + status + created_at
```

Orders:

```text
user_id + created_at
user_id + order_status
payment_status
```

Cart:

```text
session_id
```

## Verified Flow

The backend flow has been manually verified:

```text
Cart
→ Address
→ Checkout
→ Order
→ Stock Decrement
→ Cart Clear
→ Payment
→ Payment Status
→ Order Detail
→ Order History
→ Cancellation
→ Refund
→ Stock Restoration
```

Regression tests also verified:

```text
Stock overflow -> 422
Unauthorized admin request -> 401
Customer admin request -> 403
Cart ownership violation -> blocked
Other user's order -> 404
Other user's payment -> 404
Cancelled order payment -> 422
Repeated cancellation -> 422
```

## Final Validation

```bash
php artisan migrate:status
php artisan route:list
php artisan test
composer audit
```

## Production

Production environment should use:

```env
APP_ENV=production
APP_DEBUG=false
```

Use secure MySQL credentials and HTTPS.

The `.env` file and production passwords must never be committed to Git.

The mock payment gateway must be replaced with a real provider before accepting real payments.
