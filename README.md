# Reason on Wine: menu bar fix

Small, source-only patch set for the Reason 5 menu-bar bug seen with WineCX on macOS.

## What it fixes

Reason rebuilds its menu bar while handling `WM_INITMENU`. On the tested setup this leaves the menu height at zero and, in one path, leaves `items_rect` empty. Wine then cannot hit-test a click on **File**; keyboard menu activation can also place the popup over the bar. Wine's upstream MR 11667 addresses the zero-height layout. The additional patch here handles Reason 5's empty-rectangle case by deriving the menu-bar rectangle from the window frame.

The observed fix was built for CrossOver/WineCX 24.0.7, installed in the `x86_64-unix/win32u.so` slot, and loaded by Reason 5 copia. The user confirmed that clicking the menu then worked. This repository includes that one compiled x86_64 macOS library as a convenience, but does not include proprietary CrossOver source or wrapper files.

## Files

- `patches/upstream-mr11667-reference.diff`: reference snapshot of Wine MR 11667. Use only when the Wine source does not already contain that upstream change, and check its applicability against the exact Wine revision first.
- `patches/reason5-empty-menubar-fallback.patch`: the additional fallback tested with the CrossOver 24.0.7 source tree, applied after the upstream layout fix.
- `artifacts/macos-x86_64/win32u.so`: the tested binary for WineCX 24.0.7 x86_64 only. It depends on the matching `ntdll.so` and is not a generic Wine replacement.
- `scripts/install-macos.sh`: backs up and replaces the selected wrapper's `win32u.so` with a previously built x86_64 library.
- `PATCHING.md`: build, install, restore, and portability notes.

## Quick install (after building)

Quit Reason and its Wine session cleanly, then run:

```sh
./scripts/install-macos.sh "/Applications/Reason 5 copia.app" "/path/to/patched/win32u.so"
```

Or use the included tested artifact:

```sh
./scripts/install-macos.sh "/Applications/Reason 5 copia.app" \
  "./artifacts/macos-x86_64/win32u.so"
```

The script creates a timestamped backup beside the target library. It does not start or stop Reason, and it refuses a non-Mach-O or non-x86_64 input.

## Compatibility

The source change is in Wine's cross-platform `win32u` implementation. It should be adaptable to Wine on Linux and other Wine-supported Unix systems, but this repository only records a successful runtime result on CrossOver/WineCX 24.0.7 for macOS. Native Windows is not a Wine target and cannot use this patch as-is. See `PATCHING.md` before applying it to another engine or release.

## Upstream reference

Wine MR 11667 describes the menu-bar height problem affecting Reason 3–14 and its upstream fix: <https://gitlab.winehq.org/wine/wine/-/merge_requests/11667>.

The extra empty-rectangle fallback is based on Wine source distributed with CrossOver and is licensed under LGPL-2.1-or-later. The exact CrossOver source release is available from [CodeWeavers' source page](https://www.codeweavers.com/crossover/source); Wine's source is also available from [WineHQ](https://gitlab.winehq.org/wine/wine). See `LICENSE.LGPL-2.1` and the build provenance in `artifacts/macos-x86_64/README.md`.
