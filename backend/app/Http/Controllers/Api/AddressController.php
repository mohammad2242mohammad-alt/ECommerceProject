<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Address;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class AddressController extends Controller
{
    public function index(Request $request)
    {
        $addresses = Address::where('user_id', $request->user()->id)
            ->orderByDesc('is_default')
            ->latest()
            ->get();

        return response()->json([
            'success' => true,
            'message' => 'Success',
            'data' => $addresses
        ]);
    }

    public function store(Request $request)
    {
        $validated = $request->validate([
            'title' => 'required|string|max:100',
            'receiver_name' => 'required|string|max:255',
            'receiver_phone' => 'required|string|max:20',
            'province' => 'required|string|max:100',
            'city' => 'required|string|max:100',
            'address' => 'required|string',
            'postal_code' => 'required|string|max:20',
            'latitude' => 'nullable|numeric',
            'longitude' => 'nullable|numeric',
            'is_default' => 'nullable|boolean'
        ]);

        return DB::transaction(function () use ($request, $validated) {

            $userId = $request->user()->id;

            $hasAddress = Address::where('user_id', $userId)->exists();

            $isDefault = !$hasAddress
                ? true
                : ($validated['is_default'] ?? false);

            if ($isDefault) {
                Address::where('user_id', $userId)
                    ->update([
                        'is_default' => false
                    ]);
            }

            $address = Address::create([
                'user_id' => $userId,
                'title' => $validated['title'],
                'receiver_name' => $validated['receiver_name'],
                'receiver_phone' => $validated['receiver_phone'],
                'province' => $validated['province'],
                'city' => $validated['city'],
                'address' => $validated['address'],
                'postal_code' => $validated['postal_code'],
                'latitude' => $validated['latitude'] ?? null,
                'longitude' => $validated['longitude'] ?? null,
                'is_default' => $isDefault
            ]);

            return response()->json([
                'success' => true,
                'message' => 'Address created successfully',
                'data' => $address
            ], 201);
        });
    }

    public function show(Request $request, int $id)
    {
        $address = Address::where('user_id', $request->user()->id)
            ->findOrFail($id);

        return response()->json([
            'success' => true,
            'message' => 'Success',
            'data' => $address
        ]);
    }

    public function update(Request $request, int $id)
    {
        $address = Address::where('user_id', $request->user()->id)
            ->findOrFail($id);

        $validated = $request->validate([
            'title' => 'sometimes|required|string|max:100',
            'receiver_name' => 'sometimes|required|string|max:255',
            'receiver_phone' => 'sometimes|required|string|max:20',
            'province' => 'sometimes|required|string|max:100',
            'city' => 'sometimes|required|string|max:100',
            'address' => 'sometimes|required|string',
            'postal_code' => 'sometimes|required|string|max:20',
            'latitude' => 'nullable|numeric',
            'longitude' => 'nullable|numeric',
            'is_default' => 'sometimes|boolean'
        ]);

        return DB::transaction(function () use (
            $request,
            $address,
            $validated
        ) {

            if (
                isset($validated['is_default']) &&
                $validated['is_default']
            ) {
                Address::where('user_id', $request->user()->id)
                    ->where('id', '!=', $address->id)
                    ->update([
                        'is_default' => false
                    ]);
            }

            $address->update($validated);

            return response()->json([
                'success' => true,
                'message' => 'Address updated successfully',
                'data' => $address->fresh()
            ]);
        });
    }

    public function destroy(Request $request, int $id)
    {
        $address = Address::where('user_id', $request->user()->id)
            ->findOrFail($id);

        $wasDefault = $address->is_default;

        $address->delete();

        if ($wasDefault) {
            $nextAddress = Address::where(
                'user_id',
                $request->user()->id
            )->first();

            if ($nextAddress) {
                $nextAddress->update([
                    'is_default' => true
                ]);
            }
        }

        return response()->json([
            'success' => true,
            'message' => 'Address deleted successfully',
            'data' => null
        ]);
    }
}