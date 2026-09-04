@extends('admin.layout')

@section('title','تنظیمات ارسال')


@section('content')


<div class="page-header">

<h1>
تنظیمات ارسال
</h1>

</div>



<div class="card">


<form
method="POST"
action="{{ route('admin.settings.update') }}"
>

@csrf

@method('PUT')



<div class="form-grid">



<div class="form-group">

<label>
هزینه ارسال
</label>


<input
type="number"
name="shipping_price"
value="{{ old('shipping_price',$shippingPrice) }}"
>


<div class="hint">
هزینه ارسال ثابت سفارش‌ها
</div>


</div>




<div class="form-group">

<label>
ارسال رایگان از مبلغ
</label>


<input
type="number"
name="free_shipping_threshold"
value="{{ old('free_shipping_threshold',$freeShippingThreshold) }}"
>


<div class="hint">
اگر مبلغ سفارش بیشتر از این مقدار باشد ارسال رایگان می‌شود.
</div>


</div>



</div>




<button
class="btn btn-primary"
>
ذخیره تنظیمات
</button>



</form>


</div>


@endsection