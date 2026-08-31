<!DOCTYPE html>
<html lang="fa" dir="rtl">

<head>

<meta charset="UTF-8">

<meta name="viewport" content="width=device-width, initial-scale=1.0">

<title>
@yield('title','پنل مدیریت')
</title>


<style>

*{
    box-sizing:border-box;
}


body{
    margin:0;
    background:#f5f6f8;
    color:#262626;
    font-family:Tahoma,Arial,sans-serif;
}


a{
    text-decoration:none;
    color:inherit;
}


.sidebar{

    position:fixed;
    right:0;
    top:0;
    bottom:0;

    width:240px;

    padding:25px 16px;

    background:white;

    border-left:1px solid #e7e7e7;

    overflow-y:auto;
}


.brand{

    font-size:22px;
    font-weight:bold;
    margin-bottom:30px;

}


.brand span{
    color:#ef4056;
}



.nav-item{

    display:block;

    padding:12px 14px;

    margin-bottom:7px;

    border-radius:10px;

    color:#555;

}


.nav-item:hover,
.nav-item.active{

    color:#ef4056;

    background:#fff0f2;

}



.content{

    margin-right:240px;

    min-height:100vh;

}



.topbar{

    height:70px;

    padding:0 28px;

    background:white;

    border-bottom:1px solid #e7e7e7;

    display:flex;

    align-items:center;

    justify-content:space-between;

}



.main{

    padding:28px;

}



.logout{

    border:0;

    background:transparent;

    color:#ef4056;

    cursor:pointer;

    font-family:inherit;

}



.page-header{

    display:flex;

    justify-content:space-between;

    align-items:center;

    margin-bottom:22px;

}



.page-header h1{

    margin:0;

    font-size:24px;

}



.card{

    background:white;

    border-radius:14px;

    border:1px solid #ececec;

    padding:20px;

    margin-bottom:20px;

}



.btn{

    display:inline-block;

    border:0;

    border-radius:9px;

    padding:10px 15px;

    cursor:pointer;

    font-family:inherit;

    font-size:13px;

}


.btn-primary{

    background:#ef4056;

    color:white;

}


.btn-light{

    background:#f1f1f1;

    color:#333;

}



.btn-danger{

    background:#fff0f2;

    color:#c6283d;

}



table{

    width:100%;

    border-collapse:collapse;

}


th,
td{

    padding:13px 10px;

    border-bottom:1px solid #eee;

    text-align:right;

}



th{

    color:#777;

    font-size:13px;

}



.badge{

    display:inline-block;

    border-radius:999px;

    padding:6px 10px;

    font-size:12px;

}



.badge-active{

    background:#e8f7ef;

    color:#16834b;

}


.badge-inactive{

    background:#eee;

    color:#777;

}



.actions{

    display:flex;

    gap:7px;

    flex-wrap:wrap;

}



.alert{

    border-radius:10px;

    padding:13px 15px;

    margin-bottom:20px;

}


.alert-success{

    background:#e8f7ef;

    color:#166534;

}


.alert-danger{

    background:#fff0f2;

    color:#b42336;

}


.form-group{

    margin-bottom:18px;

}


.form-grid{

    display:grid;

    grid-template-columns:repeat(2,minmax(0,1fr));

    gap:18px;

}


input,
select,
textarea{

    width:100%;

    padding:11px 12px;

    border:1px solid #ddd;

    border-radius:9px;

    font-family:inherit;

}



.checkbox-row{

    display:flex;

    gap:8px;

    align-items:center;

}



</style>


</head>


<body>


<aside class="sidebar">


<div class="brand">
پنل <span>مدیریت</span>
</div>



<a href="{{ route('admin.dashboard') }}"
class="nav-item {{request()->routeIs('admin.dashboard')?'active':''}}">
داشبورد
</a>



<a href="{{ route('admin.categories.index') }}"
class="nav-item {{request()->routeIs('admin.categories.*')?'active':''}}">
دسته‌بندی‌ها
</a>



<a href="{{ route('admin.products.index') }}"
class="nav-item {{request()->routeIs('admin.products.*')?'active':''}}">
محصولات
</a>



<a href="{{ route('admin.orders.index') }}"
class="nav-item {{request()->routeIs('admin.orders.*')?'active':''}}">
سفارش‌ها
</a>



<a href="{{ route('admin.coupons.index') }}"
class="nav-item {{request()->routeIs('admin.coupons.*')?'active':''}}">
کدهای تخفیف
</a>



<a href="{{ route('admin.reviews.index') }}"
class="nav-item {{request()->routeIs('admin.reviews.*')?'active':''}}">
نظرات
</a>



<a href="{{ route('admin.settings.index') }}"
class="nav-item {{request()->routeIs('admin.settings.*')?'active':''}}">
تنظیمات
</a>



</aside>



<div class="content">



<header class="topbar">


<div>

{{ auth()->user()->name ?? 'مدیر سیستم' }}

</div>



<form method="POST"
action="{{route('admin.logout')}}">

@csrf

<button class="logout">

خروج

</button>


</form>



</header>




<main class="main">



@if(session('success'))

<div class="alert alert-success">

{{session('success')}}

</div>

@endif



@if($errors->any())

<div class="alert alert-danger">

<ul>

@foreach($errors->all() as $error)

<li>
{{$error}}
</li>

@endforeach

</ul>

</div>

@endif



@yield('content')



</main>



</div>



</body>

</html>