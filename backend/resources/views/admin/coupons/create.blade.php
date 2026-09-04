@extends('admin.layout')

@section('title', 'ایجاد کد تخفیف')

@section('content')

<div class="page-header">
    <h1>
        ایجاد کد تخفیف
    </h1>

    <a
        href="{{ route('admin.coupons.index') }}"
        class="btn btn-light"
    >
        بازگشت
    </a>
</div>


<div class="card">

<form
    method="POST"
    action="{{ route('admin.coupons.store') }}"
>

@csrf


<div class="form-grid">


<div class="form-group">

<label>
کد تخفیف
</label>

<input
    type="text"
    name="code"
    value="{{ old('code') }}"
    placeholder="مثلا OFF20"
>

</div>



<div class="form-group">

<label>
نوع تخفیف
</label>

<select name="type">

<option value="percentage">
درصدی
</option>

<option value="fixed">
مبلغ ثابت
</option>

</select>

</div>



<div class="form-group">

<label>
مقدار تخفیف
</label>

<input
    type="number"
    name="value"
    value="{{ old('value') }}"
>

</div>



<div class="form-group">

<label>
حداقل مبلغ سفارش
</label>

<input
    type="number"
    name="minimum_order_amount"
    value="{{ old('minimum_order_amount') }}"
>

</div>



<div class="form-group">

<label>
حداکثر تخفیف
</label>

<input
    type="number"
    name="maximum_discount"
    value="{{ old('maximum_discount') }}"
>

</div>



<div class="form-group">

<label>
محدودیت استفاده کل
</label>

<input
    type="number"
    name="usage_limit"
    value="{{ old('usage_limit') }}"
>

</div>



<div class="form-group">

<label>
محدودیت هر کاربر
</label>

<input
    type="number"
    name="per_user_limit"
    value="{{ old('per_user_limit') }}"
>

</div>



<div class="form-group">

<label>
شروع اعتبار
</label>

<input
    type="datetime-local"
    name="starts_at"
    value="{{ old('starts_at') }}"
>

</div>



<div class="form-group">

<label>
پایان اعتبار
</label>

<input
    type="datetime-local"
    name="ends_at"
    value="{{ old('ends_at') }}"
>

</div>


</div>



<div class="checkbox-row">

<input
    type="checkbox"
    name="is_active"
    value="1"
    checked
>

<label>
فعال باشد
</label>

</div>



<br>


<button
    class="btn btn-primary"
>
ذخیره کد تخفیف
</button>


</form>

</div>

@endsection