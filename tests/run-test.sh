#!/bin/sh
# ==================================================================== #
set -eu

PROGNAME=$(basename -- "${0}")
PROGBASE=$(d=$(dirname -- "${0}"); cd "${d}" && pwd)

# -------------------------------------------------------------------- #

if [ X0 = X"${#}" ]; then
	usage >&2
	printf 'usage: %s test...\n' "${PROGNAME}" >&2
	exit 2
fi
if [ ! -f "${PROGBASE}/${1}.tests" ]; then
	printf '[E] No such tests: %s\n' "${1}" >&2
	exit 1
fi

# -------------------------------------------------------------------- #

genin() {
	fn="${1}"
	shift

	cat << __EOF__
${fn} = import ./../${fn}.nix
r = ${fn} ${@}
r
__EOF__
}

filtr() {
	sed -n -e '/^nix-repl> r$/,/^nix-repl>/ p' | \
		sed -e '1d;$d' | \
		grep -v '^$'
}

# -------------------------------------------------------------------- #

prfail() {
	printf '[F] "%s" -> "%s" (expected "%s")\n' "${1}" "${3}" "${2}"
}

prsucc() {
	printf '[S] %s\n' "${1}"
}

run() {
	printf '[I] Running test for: %s\n' "${1}"

	grep '^[^#]' "${PROGBASE}/${1}.tests" | grep -Ev '^[[:space:]]*$' | \
	while read _line; do
		i=$(printf '%s' "${_line}" | awk -F'#' '{print $1;}' | sed -Ee 's|\s*$||')
		x=$(printf '%s' "${_line}" | awk -F'#' '{print $2;}' | sed -Ee 's|^\s*||')

		set +e
		o=$(genin "${1}" "${i}" | nix-repl 2>&1 | filtr)
		set -e

		fn=prsucc
		if [ X- = X"${x}" ]; then
			if ! printf '%s' "${o}" | grep -q '^error:'; then
				fn=prfail
			fi
		elif [ X"${x}" != X"${o}" ]; then
			fn=prfail
		fi

		$fn "${i}" "${x}" "${o}"
	done
}

while [ X != X"${1:-}" ]; do
	run "${1}"
	shift
done

# ==================================================================== #
