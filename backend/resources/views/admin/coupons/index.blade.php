@extends('admin.layout')

@section('title','کدهای تخفیف')


@section('content')

<div class="page-header">

<h1>
کدهای تخفیف
</h1>


<a
href="{{ route('admin.coupons.create') }}"
class="btn btn-primary"
>
ایجاد کد جدید
</a>

</div>


<div class="card">


<form method="GET">


<div class="filters-grid">


<input
type="text"
name="q"
placeholder="جستجو کد..."
value="{{ request('q') }}"
>


<select name="status">

<option value="">
همه
</option>

<option
value="active"
@if(request('status')==='active') selected @endif
>
فعال
</option>


<option
value="inactive"
@if(request('status')==='inactive') selected @endif
>
غیرفعال
</option>

</select>


<button class="btn btn-light">
جستجو
</button>


</div>

</form>


</div>



<div class="card">


<table>

<thead>

<tr>

<th>
کد
</th>

<th>
نوع
</th>

<th>
مقدار
</th>

<th>
استفاده
</th>

<th>
وضعیت
</th>

<th>
عملیات
</th>

</tr>

</thead>



<tbody>


@forelse($coupons as $coupon)


<tr>


<td>
{{ $coupon->code }}
</td>


<td>

@if($coupon->type === 'percentage')

درصدی

@else

مبلغ ثابت

@endif

</td>


<td>
{{ $coupon->value }}
</td>


<td>
{{ $coupon->usages_count }}
</td>


<td>


@if($coupon->is_active)

<span class="badge badge-active">
فعال
</span>

@else

<span class="badge badge-inactive">
غیرفعال
</span>

@endif


</td>


<td>


<div class="actions">


<a
href="{{ route('admin.coupons.edit',$coupon) }}"
class="btn btn-light"
>
ویرایش
</a>



<form
method="POST"
action="{{ route('admin.coupons.toggle',$coupon) }}"
>

@csrf

<button
class="btn btn-success"
>
تغییر وضعیت
</button>

</form>



<form
method="POST"
action="{{ route('admin.coupons.destroy',$coupon) }}"
>

@csrf

@method('DELETE')


<button
class="btn btn-danger"
>
حذف
</button>


</form>


</div>


</td>


</tr>


@empty


<tr>

<td colspan="6">

کدی وجود ندارد

</td>

</tr>


@endforelse


</tbody>


</table>


</div>



{{ $coupons->links() }}


@endsection