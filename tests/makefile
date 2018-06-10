
all: nix-repl
	@for t in *.tests; do \
		n=$$(basename "$${t}" .tests); \
		sh ./run-test.sh "$${n}"; \
	done


nix-repl:
	@which nix-repl >/dev/null || nix-env -i nix-repl
