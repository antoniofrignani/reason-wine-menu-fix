# Build, install, and restore

## What was actually changed

The shipped wrapper contains both Windows PE modules and Unix Wine modules. For this bug, replacing `win32u.dll` alone is insufficient: the menu implementation that was rebuilt is the Unix library `win32u.so`. The known working destination was:

```text
<Reason wrapper>.app/Contents/SharedSupport/wine/lib/wine/x86_64-unix/win32u.so
```

The path is wrapper-specific. Confirm it exists in the target bundle before using the installer. Do not replace the `i386-windows` or `x86_64-windows` PE DLLs for this fix.

## macOS: CrossOver / WineCX

1. Make a copy of the wrapper or otherwise ensure its existing Wine library can be restored. Quit Reason normally; do not kill `wineserver` while a song may have unsaved changes.
2. Obtain the Wine source and configured build tree matching the wrapper's exact WineCX version. Do not build against an arbitrary Wine checkout and put that result into CrossOver.
3. Check whether `dlls/win32u/menu.c` already has Wine MR 11667's `ensure_menu_bar_layout()` calls. If absent, apply the upstream change from `patches/upstream-mr11667-reference.diff` only if it applies cleanly to that exact source revision. The included file is a reference snapshot, not a promise that its hunks apply to later Wine releases.
4. From the Wine source root, apply the Reason 5 fallback after the upstream change:

   ```sh
   patch -p1 < /path/to/reason-wine-menu-fix/patches/reason5-empty-menubar-fallback.patch
   ```

   If the patch does not apply cleanly, stop and port the small change in `ensure_menu_bar_layout()` manually. Do not force-apply it.
5. Rebuild the Unix `win32u.so` for the same architecture as the wrapper. The verified wrapper used `x86_64-unix`; an arm64 Wine engine needs a separately built arm64 library and is rejected by the bundled installer. Cross-compilation of one library inside a larger preconfigured CrossOver build can reuse stale objects or the wrong `ntdll.so`, so use a clean build tree configured for the target architecture and retain the matching runtime dependencies.
6. Confirm the output is a Mach-O dynamic library and `lipo -archs` includes the engine's architecture. Keep its `ntdll.so` dependency compatible with the wrapper; do not install a library from another Wine build just because its filename matches.
7. Install while Reason/Wine are stopped:

   ```sh
   /path/to/reason-wine-menu-fix/scripts/install-macos.sh \
     "/Applications/Reason 5 copia.app" \
     "/path/to/build/dlls/win32u/win32u.so"
   ```

8. Launch the wrapper and verify the **File** menu with a mouse click. Also check keyboard activation and popup placement. Close Reason normally to release the loaded library before restoring or replacing it again.

The tested patched `win32u.so` is included at `artifacts/macos-x86_64/win32u.so`. Its SHA-256 is `790bf7b0e141d2ba37ae20c140c9af1ab44b8c7e99a4aaf575e70abbf7e3c853`. It links to `@rpath/ntdll.so` and Apple Carbon/AppKit; only use it with the matching WineCX 24.0.7 x86_64 engine. A rebuild will not necessarily have the same hash.

### Restore

The installer prints the timestamped backup path it creates. With the wrapper fully stopped, restore that backup over `Contents/SharedSupport/wine/lib/wine/x86_64-unix/win32u.so`. Keep the patched file until the restored wrapper has been checked.

## Linux and other Wine platforms

The C code uses Wine's internal `NtUser*` functions and the menu implementation, so the source-level change is not inherently macOS-only. For a matching Wine source revision, apply the upstream fix if needed, then the fallback patch, and rebuild Wine for the target platform using that platform's normal Wine build process. Install the resulting Unix `win32u.so` only into the corresponding Wine build/prefix and architecture. The included Mach-O artifact cannot be used on Linux or other operating systems.

Linux, FreeBSD, other CrossOver releases, and other Wine versions have not been tested here. Their source revisions, build systems, architectures, dependency names, and install paths can differ. Do not copy the macOS library to those systems. Native Windows is unsupported by this patch set.

## Source and licensing

The upstream layout fix is tracked as Wine MR 11667. The Reason 5 fallback is a modification of Wine's LGPL-2.1-or-later code. CrossOver source and compiled libraries are not redistributed in this repository. The complete LGPL text is in `LICENSE.LGPL-2.1`.
