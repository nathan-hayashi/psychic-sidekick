# SIDE-PAGES-1, explained plainly

## What changed

The form got a front door on the web: GitHub Pages now serves this repo's `index.html`
straight from the `dev` branch root at <https://nathan-hayashi.github.io/psychic-sidekick/>.
No build step exists, so the hosted page and your local file are byte-identical — "same
bytes" is true by construction, not by promise. GitHub does the serving; the page itself
still never phones home, and the suite's self-containment arms keep proving that half. The
repo homepage now points at the hosted page (a DECLARED overwrite — it previously pointed at
the parent repo, and the parent link moved into the README body instead).

## Why the suite verifies and never creates

Enablement is a one-time outward act taken at the gate's token (with an operator-click
fallback if the API refuses); the suite's job forever after is verification, in three honest
states: enabled-and-serving-dev-root is PASS, disabled-under-working-auth is FAIL (the
regression the arm exists for), and everything else — no auth, transport failure, rate
limits — is an announced SKIP naming what it saw, because a hermetic suite must not go red
on someone else's network weather.

## Verify it yourself

```
./scripts/validate-sidekick.sh | grep -A4 'hosted lane'
gh api repos/nathan-hayashi/psychic-sidekick/pages --jq '.source'
```

## What could break, and what catches it

Pages turned off → the FAIL state, by name. The source moved off dev:/ → the drift arm. The
homepage repointed → the equality arm. The README losing the URL → the unconditional arm that
runs everywhere, gh or not.
