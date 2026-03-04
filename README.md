# Personal website

## Run locally

Use the same setup as [GitHub Pages with Jekyll](https://jekyllrb.com/docs/github-pages/):

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

3. Open **http://localhost:4000**.

## Run Vale to lint prose

[Vale](https://vale.sh/) lints Markdown for style and readability. Install with `brew install vale`, then sync packages and run:

```bash
vale sync
vale .
```

- **Config:** `.vale.ini`—MinAlertLevel = warning; uses packages Readability, Google, write-good plus custom Prose and Restack vocab.
- Toggle rules in `.vale.ini` (for example, `Google.We = warning`, `Vale.Spelling = NO`). See [Vale docs](https://vale.sh/docs/).

A GitHub Action runs Vale on every PR that touches Markdown or Vale config; the job runs `vale sync` then Vale, and fails on errors.
