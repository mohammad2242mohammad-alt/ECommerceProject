<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\Coupon;
use Illuminate\Http\Request;
use Illuminate\Validation\Rule;
use Illuminate\Validation\ValidationException;

class AdminCouponController extends Controller
{
    public function index(Request $request)
    {
        $query = Coupon::withCount('usages')
            ->latest();

        if ($request->filled('q')) {
            $query->where(
                'code',
                'like',
                '%' . trim($request->q) . '%'
            );
        }

        if ($request->filled('status')) {
            $query->where(
                'is_active',
                $request->status === 'active'
            );
        }

        $coupons = $query
            ->paginate(20)
            ->withQueryString();

        return view(
            'admin.coupons.index',
            compact('coupons')
        );
    }

    public function create()
    {
        return view(
            'admin.coupons.create'
        );
    }

    public function store(Request $request)
    {
        Coupon::create(
            $this->validatedData($request)
        );

        return redirect()
            ->route('admin.coupons.index')
            ->with(
                'success',
                'کد تخفیف با موفقیت ایجاد شد.'
            );
    }

    public function edit(Coupon $coupon)
    {
        return view(
            'admin.coupons.edit',
            compact('coupon')
        );
    }

    public function update(
        Request $request,
        Coupon $coupon
    ) {
        $coupon->update(
            $this->validatedData(
                $request,
                $coupon
            )
        );

        return redirect()
            ->route('admin.coupons.index')
            ->with(
                'success',
                'کد تخفیف با موفقیت ویرایش شد.'
            );
    }

    public function toggle(Coupon $coupon)
    {
        $coupon->update([
            'is_active' =>
                !$coupon->is_active,
        ]);

        return back()->with(
            'success',
            'وضعیت کد تخفیف تغییر کرد.'
        );
    }

    public function destroy(Coupon $coupon)
    {
        if ($coupon->usages()->exists()) {
            return back()->withErrors([
                'coupon' =>
                    'این کد تخفیف قبلاً استفاده شده و قابل حذف نیست؛ آن را غیرفعال کنید.',
            ]);
        }

        $coupon->delete();

        return back()->with(
            'success',
            'کد تخفیف حذف شد.'
        );
    }

    private function validatedData(
        Request $request,
        ?Coupon $coupon = null
    ): array {
        $validated = $request->validate([
            'code' => [
                'required',
                'string',
                'max:100',

                Rule::unique(
                    'coupons',
                    'code'
                )->ignore(
                    $coupon?->id
                ),
            ],

            'type' => [
                'required',
                Rule::in([
                    'percentage',
                    'fixed',
                ]),
            ],

            'value' => [
                'required',
                'numeric',
                'min:0',
            ],

            'minimum_order_amount' => [
                'nullable',
                'numeric',
                'min:0',
            ],

            'maximum_discount' => [
                'nullable',
                'numeric',
                'min:0',
            ],

            'starts_at' => [
                'nullable',
                'date',
            ],

            'ends_at' => [
                'nullable',
                'date',
                'after_or_equal:starts_at',
            ],

            'usage_limit' => [
                'nullable',
                'integer',
                'min:1',
            ],

            'per_user_limit' => [
                'nullable',
                'integer',
                'min:1',
            ],
        ]);

        if (
            $validated['type'] ===
                'percentage' &&
            (float) $validated['value'] > 100
        ) {
            throw ValidationException::withMessages([
                'value' => [
                    'درصد تخفیف نمی‌تواند بیشتر از 100 باشد.',
                ],
            ]);
        }

        $validated['code'] =
            strtoupper(
                trim(
                    $validated['code']
                )
            );

        $validated['is_active'] =
            $request->boolean(
                'is_active'
            );

        return $validated;
    }
}