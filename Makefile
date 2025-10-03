all: check_simple check_prettier

check_simple:
	@docker run --platform linux/amd64 -v .:/tmp:ro --rm ghcr.io/tcort/markdown-link-check:stable -i .vscode -c /tmp/link-check.json /tmp | \
	  egrep "(ERROR:|\[✖\].*Status)" && \
	  exit 1 || \
	  true

check_simple_verbose:
	@docker run --platform linux/amd64 -v .:/tmp:ro --rm ghcr.io/tcort/markdown-link-check:stable -i .vscode -c /tmp/link-check.json /tmp

check_prettier:
	@find . -name "*.md" | grep -v LICENSE.md | xargs npx prettier -l

prettier:
	@find . -name "*.md" | grep -v LICENSE.md | xargs npx prettier -w

