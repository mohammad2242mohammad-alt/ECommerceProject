@extends('admin.layout')

@section('title', 'سفارش‌ها')

@section('content')

<div class="page-header">
    <h1>
        سفارش‌ها
    </h1>
</div>


<div class="card">

<form method="GET">

<div class="filters-grid">

<input
    name="q"
    value="{{ request('q') }}"
    placeholder="جستجوی سفارش یا مشتری"
>


<select name="order_status">

<option value="">
همه وضعیت سفارش
</option>

@foreach($statuses as $status)

<option
value="{{ $status }}"
@if(request('order_status') === $status)
selected
@endif
>
{{ $status }}
</option>

@endforeach

</select>


<select name="payment_status">

<option value="">
همه وضعیت پرداخت
</option>

<option
value="paid"
@if(request('payment_status') === 'paid')
selected
@endif
>
پرداخت شده
</option>


<option
value="unpaid"
@if(request('payment_status') === 'unpaid')
selected
@endif
>
پرداخت نشده
</option>

</select>


<button class="btn btn-primary">
فیلتر
</button>


</div>

</form>

</div>



<div class="card">

<table>

<thead>

<tr>

<th>
شماره سفارش
</th>

<th>
مشتری
</th>

<th>
تعداد کالا
</th>

<th>
مبلغ
</th>

<th>
وضعیت
</th>

<th>
پرداخت
</th>

<th>
عملیات
</th>

</tr>

</thead>


<tbody>

@foreach($orders as $order)

<tr>

<td>
{{ $order->order_number }}
</td>


<td>

{{ $order->user?->name ?? '-' }}

<br>

<small>
{{ $order->user?->phone }}
</small>

</td>


<td>
{{ $order->items_count }}
</td>


<td>
{{ number_format($order->total) }}
تومان
</td>


<td>
{{ $order->order_status }}
</td>


<td>
{{ $order->payment_status }}
</td>


<td>

<a
class="btn btn-light"
href="{{ route('admin.orders.show',$order) }}"
>
مشاهده
</a>

</td>


</tr>


@endforeach


</tbody>

</table>


</div>


{{ $orders->links() }}


@endsection