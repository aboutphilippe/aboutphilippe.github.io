.PHONY: serve serve-drafts build build-drafts lint sync

# Live site only (published _posts). Drafts stay out of _site, sitemap, and robots.
serve:
	bundle exec jekyll serve --host 127.0.0.1 --port 4000 --livereload

build:
	bundle exec jekyll build

# Local draft preview only. Writes to _site-drafts/ (gitignored), never the live site.
serve-drafts:
	bundle exec jekyll serve --drafts --unpublished --host 127.0.0.1 --port 4001 --destination _site-drafts --livereload

build-drafts:
	bundle exec jekyll build --drafts --unpublished --destination _site-drafts

# Sync Vale packages (run once after install or when .vale.ini changes)
sync:
	vale sync

# Lint prose. Excludes generated Jekyll output, draft preview builds, and vendor dirs.
lint:
	vale --glob='!{_site,_site-drafts,scripts/.venv,vendor,node_modules}/**' .
