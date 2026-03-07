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

I use [Vale](https://vale.sh/) to lint Markdown for style and readability. Install Vale (`brew install vale`), sync packages, then run the commands below.

```bash
vale sync
vale .
```
