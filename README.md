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

[Vale](https://vale.sh/) lints Markdown for style and readability. Install Vale (`brew install vale`), sync packages, then run:

```bash
vale sync
vale _posts/ index.md README.md
```

(Lint source Markdown only. Omit `_site/` to avoid linting Jekyll output.)

- **Committed:** `styles/Personal/` (**Personal** rules): avoid (filler, wordy openers, one, range/conclusions, hedging, clichés), formal transitions from ai-tells, encourage (direct address, rhetorical question), sentence length (suggestion: under 35 words per sentence).
- **Synced:** `styles/` (Google, write-good, Readability, [**signs-of-ai-writing**](https://github.com/ammil-industries/vale-signs-of-ai-writing), [**vale-ai-tells**](https://github.com/tbhb/vale-ai-tells)). See `.vale.ini` to disable or soften overlapping rules.
- Run `vale --minAlertLevel=suggestion` to see suggestions (e.g. long sentences, “add a question”, “address the reader”).
- Toggle rules in `.vale.ini`. See [Vale docs](https://vale.sh/docs/).

CI runs `vale sync` then Vale on `_posts/`, `index.md`, and `README.md` when Markdown or Vale config changes.
