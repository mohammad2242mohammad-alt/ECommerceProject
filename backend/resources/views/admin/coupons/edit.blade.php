@extends('admin.layout')

@section('title','ویرایش کد تخفیف')


@section('content')

<div class="page-header">

<h1>
ویرایش کد تخفیف
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
action="{{ route('admin.coupons.update',$coupon) }}"
>

@csrf

@method('PUT')


<div class="form-grid">


<div class="form-group">

<label>
کد تخفیف
</label>


<input
type="text"
name="code"
value="{{ old('code',$coupon->code) }}"
>


</div>



<div class="form-group">

<label>
نوع تخفیف
</label>


<select name="type">


<option
value="percentage"
@if($coupon->type==='percentage') selected @endif
>
درصدی
</option>


<option
value="fixed"
@if($coupon->type==='fixed') selected @endif
>
مبلغ ثابت
</option>


</select>


</div>



<div class="form-group">

<label>
مقدار
</label>


<input
type="number"
name="value"
value="{{ old('value',$coupon->value) }}"
>


</div>



<div class="form-group">

<label>
حداقل مبلغ سفارش
</label>


<input
type="number"
name="minimum_order_amount"
value="{{ old('minimum_order_amount',$coupon->minimum_order_amount) }}"
>


</div>



<div class="form-group">

<label>
حداکثر تخفیف
</label>


<input
type="number"
name="maximum_discount"
value="{{ old('maximum_discount',$coupon->maximum_discount) }}"
>


</div>



<div class="form-group">

<label>
محدودیت استفاده
</label>


<input
type="number"
name="usage_limit"
value="{{ old('usage_limit',$coupon->usage_limit) }}"
>


</div>



<div class="form-group">

<label>
محدودیت هر کاربر
</label>


<input
type="number"
name="per_user_limit"
value="{{ old('per_user_limit',$coupon->per_user_limit) }}"
>


</div>


</div>



<div class="checkbox-row">


<input
type="checkbox"
name="is_active"
value="1"
@if($coupon->is_active) checked @endif
>


<label>
فعال باشد
</label>


</div>



<br>



<button
class="btn btn-primary"
>
ذخیره تغییرات
</button>



</form>


</div>


@endsection