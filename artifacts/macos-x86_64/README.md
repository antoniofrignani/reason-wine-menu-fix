# Included macOS binary

- File: `win32u.so`
- Format: Mach-O 64-bit shared library, x86_64
- Built from: CodeWeavers CrossOver/WineCX 24.0.7 source, Wine 9.0 lineage, with upstream Wine MR 11667 already present and `patches/reason5-empty-menubar-fallback.patch` applied
- Runtime target: the matching CrossOver/WineCX 24.0.7 x86_64 engine
- SHA-256: `790bf7b0e141d2ba37ae20c140c9af1ab44b8c7e99a4aaf575e70abbf7e3c853`
- Dynamic dependencies include `@rpath/ntdll.so`, Carbon, and AppKit

The patched library was loaded by Reason 5 copia, and the user confirmed that clicking **File** opened the menu. The library is provided under Wine's LGPL-2.1-or-later terms. This repository contains the patch layer, not the complete CrossOver source tree; obtain the corresponding source release from [CodeWeavers](https://www.codeweavers.com/crossover/source) to rebuild it. Do not redistribute this artifact as a general-purpose Wine library.
