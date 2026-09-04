@extends('admin.layout')

@section('title', 'جزئیات سفارش')

@section('content')

<div class="page-header">

    <h1>
        سفارش {{ $order->order_number }}
    </h1>

    <a
        href="{{ route('admin.orders.index') }}"
        class="btn btn-light"
    >
        بازگشت
    </a>

</div>


<div class="card">

<h3>
اطلاعات سفارش
</h3>

<p>
شماره سفارش:
<strong>
{{ $order->order_number }}
</strong>
</p>


<p>
مشتری:
<strong>
{{ $order->user->name ?? '-' }}
</strong>
</p>


<p>
موبایل:
<strong>
{{ $order->user->phone ?? '-' }}
</strong>
</p>


<p>
مبلغ کل:
<strong>
{{ number_format($order->total) }}
</strong>
</p>


<p>
وضعیت پرداخت:
<strong>
{{ $order->payment_status }}
</strong>
</p>


</div>



<div class="card">

<h3>
تغییر وضعیت سفارش
</h3>


<form
method="POST"
action="{{ route('admin.orders.status', $order) }}"
>

@csrf

@method('PUT')


<div class="form-group">


<select name="order_status">


@foreach($statuses as $status)


<option
value="{{ $status }}"
{{ $order->order_status === $status ? 'selected' : '' }}
>

{{ $status }}

</option>


@endforeach


</select>


</div>


<button
class="btn btn-primary"
>
ذخیره وضعیت
</button>


</form>


</div>




<div class="card">

<h3>
محصولات سفارش
</h3>


<table>

<thead>

<tr>

<th>
محصول
</th>

<th>
تعداد
</th>

<th>
قیمت
</th>

</tr>

</thead>


<tbody>


@foreach($order->items as $item)


<tr>

<td>
{{ $item->product_name ?? $item->product_name_snapshot }}
</td>


<td>
{{ $item->quantity }}
</td>


<td>
{{ number_format($item->price) }}
</td>


</tr>


@endforeach


</tbody>


</table>


</div>



@endsection