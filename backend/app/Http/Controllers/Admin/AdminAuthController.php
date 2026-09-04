<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\User;
use Illuminate\Http\RedirectResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Hash;
use Illuminate\View\View;

class AdminAuthController extends Controller
{
    public function showLogin(): View|RedirectResponse
    {
        $user = Auth::user();

        if (
            $user &&
            $user->role === 'admin' &&
            $user->is_active
        ) {
            return redirect()->route('admin.dashboard');
        }

        return view('admin.login');
    }

    public function login(Request $request): RedirectResponse
    {
        $validated = $request->validate([
            'phone' => [
                'required',
                'string',
                'regex:/^09\d{9}$/',
            ],
            'password' => [
                'required',
                'string',
                'min:8',
            ],
        ]);

        $user = User::where(
            'phone',
            $validated['phone']
        )->first();

        if (
            !$user ||
            !Hash::check(
                $validated['password'],
                $user->password
            )
        ) {
            return back()
                ->withErrors([
                    'phone' => 'شماره موبایل یا رمز عبور اشتباه است.',
                ])
                ->onlyInput('phone');
        }

        if (
            !$user->is_active ||
            $user->role !== 'admin'
        ) {
            return back()
                ->withErrors([
                    'phone' => 'این حساب اجازه ورود به پنل مدیریت را ندارد.',
                ])
                ->onlyInput('phone');
        }

        Auth::login($user);

        $request->session()->regenerate();

        return redirect()->route('admin.dashboard');
    }

    public function logout(Request $request): RedirectResponse
    {
        Auth::logout();

        $request->session()->invalidate();
        $request->session()->regenerateToken();

        return redirect()->route('admin.login');
    }
}