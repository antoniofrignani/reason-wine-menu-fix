#!/bin/bash
set -euo pipefail

usage() {
  echo "Usage: $0 /path/to/Wrapper.app /path/to/patched/win32u.so" >&2
  exit 2
}

[[ $# -eq 2 ]] || usage
app_path=${1%/}
source_so=$2
relative_target="Contents/SharedSupport/wine/lib/wine/x86_64-unix/win32u.so"
target="$app_path/$relative_target"

[[ -d "$app_path" ]] || { echo "Wrapper not found: $app_path" >&2; exit 1; }
[[ -f "$source_so" ]] || { echo "Built library not found: $source_so" >&2; exit 1; }
[[ -f "$target" ]] || { echo "Expected target not found: $target" >&2; exit 1; }

file "$source_so" | grep -q 'Mach-O' || { echo "Input is not a Mach-O library" >&2; exit 1; }
architectures=$(lipo -archs "$source_so")
[[ " $architectures " == *" x86_64 "* ]] || {
  echo "Input must contain x86_64; found: $architectures" >&2
  exit 1
}

if pgrep -f "$app_path/Contents/SharedSupport/wine" >/dev/null 2>&1; then
  echo "Reason appears to be running from this wrapper. Quit it normally and retry." >&2
  exit 1
fi

stamp=$(date '+%Y%m%d-%H%M%S')
backup="$target.backup-$stamp"
temporary="$target.new-$$"

cp -p "$target" "$backup"
trap 'rm -f "$temporary"' EXIT
install -m 755 "$source_so" "$temporary"
mv -f "$temporary" "$target"
trap - EXIT

echo "Installed: $target"
echo "Backup:    $backup"
echo "SHA-256:   $(shasum -a 256 "$target" | awk '{print $1}')"
echo "Restart the wrapper. The running Wine process must be new to load this file."
