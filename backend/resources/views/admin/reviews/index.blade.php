@extends('admin.layout')

@section('title','نظرات')

@section('content')

<div class="page-header">
    <h1>
        نظرات کاربران
    </h1>
</div>


<div class="card">

<table>

<thead>
<tr>
<th>کاربر</th>
<th>محصول</th>
<th>امتیاز</th>
<th>متن</th>
<th>وضعیت</th>
<th>عملیات</th>
</tr>
</thead>


<tbody>

@foreach($reviews as $review)

<tr>

<td>
{{ $review->user?->name ?? $review->user?->phone }}
</td>


<td>
{{ $review->product?->name }}
</td>


<td>
{{ $review->rating }}/5
</td>


<td>
{{ $review->title }}
<br>
{{ $review->body }}
</td>


<td>

<form
method="POST"
action="{{ route('admin.reviews.status',$review) }}"
>

@csrf
@method('PUT')


<select name="status">

<option value="pending"
@if($review->status==='pending') selected @endif
>
در انتظار
</option>


<option value="approved"
@if($review->status==='approved') selected @endif
>
تایید شده
</option>


<option value="rejected"
@if($review->status==='rejected') selected @endif
>
رد شده
</option>

</select>


<button class="btn btn-success">
ذخیره
</button>

</form>

</td>


<td>

<form
method="POST"
action="{{ route('admin.reviews.destroy',$review) }}"
>

@csrf
@method('DELETE')


<button class="btn btn-danger">
حذف
</button>


</form>

</td>


</tr>

@endforeach


</tbody>

</table>


</div>

@endsection