#!/usr/bin/env sh

if [ "$ZED_WSL_DEBUG_INFO" = true ]; then
	set -x
fi

ZED_PATH="$(dirname "$(realpath "$0")")"

IN_WSL=false
if [ -n "$WSL_DISTRO_NAME" ]; then
	# $WSL_DISTRO_NAME is available since WSL builds 18362, also for WSL2
	IN_WSL=true
fi

if [ $IN_WSL = true ]; then
	WSL_USER="$USER"
	if [ -z "$WSL_USER" ]; then
		WSL_USER="$USERNAME"
	fi

	encode_path() {
		# Prefer python for robust URL encoding; fall back to space-only encoding.
		if command -v python3 >/dev/null 2>&1; then
			python3 - "$1" <<'PY'
import sys
import urllib.parse

path = sys.argv[1]
# Keep path separators and common safe characters untouched.
print(urllib.parse.quote(path, safe="/-._~:@"))
PY
		else
			# Minimal encoding to keep Url::parse happy for simple cases.
			printf '%s' "$1" | sed 's/ /%20/g'
		fi
	}

	convert_arg() {
		arg="$1"
		case "$arg" in
		-*) printf '%s\n' "$arg"; return ;;
		*://*) printf '%s\n' "$arg"; return ;;
		esac

		path_part="${arg%%:*}"
		suffix="${arg#"$path_part"}"
		abs_path="$(realpath -m "$path_part" 2>/dev/null || readlink -f "$path_part" 2>/dev/null || (cd "$path_part" 2>/dev/null && pwd) || printf '%s' "$path_part")"
		encoded_path="$(encode_path "$abs_path")"
		printf 'wsl://%s%s%s\n' "$WSL_DISTRO_NAME" "$encoded_path" "$suffix"
	}

	converted_args=()
	for arg in "$@"; do
		converted_args+=("$(convert_arg "$arg")")
	done

	"$ZED_PATH/zed.exe" "${converted_args[@]}"
	exit $?
else
	"$ZED_PATH/zed.exe" "$@"
	exit $?
fi
