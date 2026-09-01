# SIDE-R2, explained plainly

## What changed

The page grew its phone surface: a Destination control with exactly two lanes (local = the plain
contract, remote = the prompt pack from SIDE-R1), and one mobile media query carrying the whole
phone law — 16px inputs so mobile browsers never zoom-jump, 44px tap targets, a compile bar that
sticks to the bottom of the screen. The README gained a "From your phone" section.

## Why

The remote lane's brain shipped last gate; this is its body. You compile on the phone, paste
into Claude mobile, and the preamble does the rest. Zero-network still holds — nothing is
served, nothing phones home; the file travels however you already move files.

## Verify it yourself

```
./scripts/validate-sidekick.sh    # E3 static arms + J2 in-engine fit meter
grep -c 'data-sw="' index.html    # 2 — the lane count's machine anchor
```

## What could break, and what catches it

Add or drop a lane → two anchors (lane-opt, data-sw) and the README **2 lanes** binding all
fail. A fixed width wide enough to overflow a phone → the static scanner catches it on every
clone, proven by a 900px div planted in a scratch copy. Where a browser exists, J2 measures the
real layout in-engine: an instrumented copy must report FITS at 390px and its planted twin must
report OVERFLOW — on browserless hosts those legs are a stated SKIP and the static arms still run.
