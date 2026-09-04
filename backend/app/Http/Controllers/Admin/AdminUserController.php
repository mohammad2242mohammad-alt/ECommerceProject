<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\User;

class AdminUserController extends Controller
{
    public function index()
    {
        $users = User::latest()->paginate(20);

        return view('admin.users.index', compact('users'));
    }


    public function toggle(User $user)
    {
        $user->update([
            'is_active' => !$user->is_active,
        ]);

        return back()->with(
            'success',
            'User status updated'
        );
    }
}