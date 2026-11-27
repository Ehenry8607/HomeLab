#!/usr/bin/env bash
# Builds the docs website into site/.
# Only files tracked by git are published, so local-only files never reach the site.
set -euo pipefail
cd "$(dirname "$0")/.."

rm -rf .site-src site
mkdir .site-src
git ls-files -z \
    | grep -zvE '^(scripts/|mkdocs\.yml$|requirements\.txt$|wrangler\.jsonc$|\.gitignore$)' \
    | xargs -0 cp --parents -t .site-src/

mkdocs build --clean
