@extends('admin.layout')

@section('content')

<h1>Users</h1>

<table class="table">
    <thead>
        <tr>
            <th>ID</th>
            <th>Name</th>
            <th>Phone</th>
            <th>Role</th>
            <th>Status</th>
            <th>Action</th>
        </tr>
    </thead>

    <tbody>
        @foreach($users as $user)

        <tr>
            <td>{{ $user->id }}</td>

            <td>
                {{ $user->name ?? '-' }}
            </td>

            <td>
                {{ $user->phone }}
            </td>

            <td>
                {{ $user->role }}
            </td>

            <td>
                {{ $user->is_active ? 'Active' : 'Inactive' }}
            </td>

            <td>

                <form method="POST"
                    action="{{ route('admin.users.toggle',$user) }}">

                    @csrf

                    <button type="submit">
                        Toggle
                    </button>

                </form>

            </td>

        </tr>

        @endforeach
    </tbody>
</table>


{{ $users->links() }}

@endsection