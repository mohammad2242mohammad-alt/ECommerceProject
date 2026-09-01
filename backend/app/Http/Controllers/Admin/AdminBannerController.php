<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\Banner;
use Illuminate\Http\Request;

class AdminBannerController extends Controller
{

    public function index()
    {
        $banners = Banner::latest()->paginate(20);

        return view(
            'admin.banners.index',
            compact('banners')
        );
    }


    public function create()
    {
        return view(
            'admin.banners.create'
        );
    }


    public function store(Request $request)
    {
        $validated = $request->validate([

            'title' => [
                'required',
                'string',
                'max:255'
            ],

            'image' => [
                'required',
                'string',
                'max:255'
            ],

            'link_type' => [
                'nullable',
                'string',
                'max:50'
            ],

            'link_value' => [
                'nullable',
                'string',
                'max:255'
            ],

            'sort_order' => [
                'nullable',
                'integer'
            ],

            'starts_at' => [
                'nullable',
                'date'
            ],

            'ends_at' => [
                'nullable',
                'date'
            ],

        ]);


        $validated['is_active'] =
            $request->has('is_active');


        Banner::create($validated);


        return redirect()
            ->route('admin.banners.index')
            ->with(
                'success',
                'Banner created successfully'
            );
    }



    public function edit(Banner $banner)
    {
        return view(
            'admin.banners.edit',
            compact('banner')
        );
    }



    public function update(
        Request $request,
        Banner $banner
    ) {

        $validated = $request->validate([

            'title' => [
                'required',
                'string',
                'max:255'
            ],

            'image' => [
                'required',
                'string',
                'max:255'
            ],

            'link_type' => [
                'nullable',
                'string',
                'max:50'
            ],

            'link_value' => [
                'nullable',
                'string',
                'max:255'
            ],

            'sort_order' => [
                'nullable',
                'integer'
            ],

            'starts_at' => [
                'nullable',
                'date'
            ],

            'ends_at' => [
                'nullable',
                'date'
            ],

        ]);


        $validated['is_active'] =
            $request->has('is_active');


        $banner->update($validated);


        return redirect()
            ->route('admin.banners.index')
            ->with(
                'success',
                'Banner updated successfully'
            );
    }



    public function destroy(Banner $banner)
    {
        $banner->delete();


        return redirect()
            ->route('admin.banners.index')
            ->with(
                'success',
                'Banner deleted successfully'
            );
    }



    public function toggle(Banner $banner)
    {
        $banner->update([
            'is_active' =>
                !$banner->is_active
        ]);


        return back();
    }

}