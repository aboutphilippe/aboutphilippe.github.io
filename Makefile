.PHONY: serve build lint lint-sync

# Run the site locally on http://127.0.0.1:4000
serve:
	bundle exec jekyll serve

# Build the static site into _site/
build:
	bundle exec jekyll build

# Sync Vale packages (run once after install or when .vale.ini changes)
sync:
	vale sync

# Lint prose. Excludes generated Jekyll output (_site/), the Python
# helper venv (scripts/.venv/), and any Ruby or Node vendor directories
# so Vale only checks prose that lives in the repo.
lint:
	vale --glob='!{_site,scripts/.venv,vendor,node_modules}/**' .
