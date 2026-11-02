# Personal website

You'll find the source for my personal site here.

## Run locally

Want to run the site locally? Use the same setup as [GitHub Pages with Jekyll](https://jekyllrb.com/docs/github-pages/). You need:

1. **Use Ruby 3.2** (matches what GitHub Pages uses):

   ```bash
   rbenv install 3.2.0   # if you use rbenv
   rbenv local 3.2.0    # sets .ruby-version for this repo
   ```

   Or with Homebrew: `brew install ruby@3.2` and ensure that Ruby comes first in your `PATH`.

2. **Install and serve:**

   ```bash
   bundle install
   bundle exec jekyll serve
   ```

3. Open **http://127.0.0.1:4000**.

## Run Vale to lint prose

I use [Vale](https://vale.sh/) to lint Markdown for style and readability. Install Vale (`brew install vale`), sync packages once, then run the linter.

```bash
make sync   # one-time: downloads style packages into styles/
make lint   # lint prose
```

## Drafts vs published posts

Published writing lives in `_posts/` and appears on the homepage, sitemap, and robots-allowed site.

Work-in-progress articles live in `_drafts/` (plus notes in `_editorial/`). A normal `make serve` / `make build` never includes them, so they stay out of `sitemap.xml` and the public Writing list.

To preview drafts locally without mixing them into the live site:

```bash
make serve-drafts   # http://127.0.0.1:4001 , output in _site-drafts/
```

When a draft is ready, move it into `_posts/` with a dated filename (`YYYY-MM-DD-slug.md`) and drop `published: false`.

