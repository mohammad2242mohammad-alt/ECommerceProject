<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\Banner;
use Illuminate\Http\RedirectResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Storage;
use Illuminate\View\View;

class AdminBannerController extends Controller
{
    public function index(): View
    {
        $banners = Banner::query()
            ->orderBy('sort_order')
            ->latest('id')
            ->paginate(20);

        return view('admin.banners.index', compact('banners'));
    }

    public function create(): View
    {
        return view('admin.banners.create');
    }

    public function store(Request $request): RedirectResponse
    {
        $validated = $this->validateBanner($request);
        $validated['image'] = $this->resolveImage($request, $validated['image'] ?? null);
        $validated['is_active'] = $request->boolean('is_active');

        Banner::create($validated);

        return redirect()
            ->route('admin.banners.index')
            ->with('success', 'بنر با موفقیت ایجاد شد.');
    }

    public function edit(Banner $banner): View
    {
        return view('admin.banners.edit', compact('banner'));
    }

    public function update(Request $request, Banner $banner): RedirectResponse
    {
        $validated = $this->validateBanner($request, false);

        if ($request->hasFile('image_file')) {
            if ($banner->image && !filter_var($banner->image, FILTER_VALIDATE_URL)) {
                Storage::disk('public')->delete($banner->image);
            }

            $validated['image'] = $this->resolveImage($request, null);
        } elseif (array_key_exists('image', $validated) && $validated['image'] !== $banner->image) {
            $validated['image'] = $validated['image'] ?: $banner->image;
        }

        $validated['is_active'] = $request->boolean('is_active');
        $banner->update($validated);

        return redirect()
            ->route('admin.banners.index')
            ->with('success', 'بنر با موفقیت ویرایش شد.');
    }

    public function destroy(Banner $banner): RedirectResponse
    {
        if ($banner->image && !filter_var($banner->image, FILTER_VALIDATE_URL)) {
            Storage::disk('public')->delete($banner->image);
        }

        $banner->delete();

        return redirect()
            ->route('admin.banners.index')
            ->with('success', 'بنر حذف شد.');
    }

    public function toggle(Banner $banner): RedirectResponse
    {
        $banner->update(['is_active' => !$banner->is_active]);

        return back()->with('success', 'وضعیت بنر تغییر کرد.');
    }

    private function validateBanner(Request $request, bool $requiredImage = true): array
    {
        return $request->validate([
            'title' => ['required', 'string', 'max:255'],
            'image' => [
                $requiredImage ? 'required_without:image_file' : 'nullable',
                'nullable',
                'string',
                'max:255',
            ],
            'image_file' => [
                $requiredImage ? 'required_without:image' : 'nullable',
                'nullable',
                'image',
                'mimes:jpg,jpeg,png,webp',
                'max:4096',
            ],
            'link_type' => ['nullable', 'string', 'max:50'],
            'link_value' => ['nullable', 'string', 'max:255'],
            'sort_order' => ['nullable', 'integer', 'min:0'],
            'starts_at' => ['nullable', 'date'],
            'ends_at' => ['nullable', 'date', 'after_or_equal:starts_at'],
        ]);
    }

    private function resolveImage(Request $request, ?string $fallback): ?string
    {
        if ($request->hasFile('image_file')) {
            return $request->file('image_file')->store('banners', 'public');
        }

        return $fallback;
    }
}
