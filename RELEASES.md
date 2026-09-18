# Releases

## 2026-09-17 — First deploy
- **What deployed:** https://abstractor.levelbrook.com (Box B, container `abstractor`, shared `lb-postgres` db `abstractor_production`), seeded with 67 codes, 3 Excludes1 pairs, 9 encounters, 16 eval cases.
- **Changed:** initial release. Coding agent (Gemini with response schema, rules baseline), grounding gate, inline Hotwire review, rules engine (8 rules), exactly-once finalize, append-only events, eval harness. 17 tests / 63 assertions green before build.
- **How:** `rsync` to `/root/abstractor`; `docker build` on the box; `docker run --network kamal --memory 300m --env-file /root/abstractor/.env.prod`; `db:prepare` + `db:seed`; `kamal-proxy deploy abstractor --target abstractor:3000 --host abstractor.levelbrook.com --tls`; CF A record `abstractor` -> 5.78.227.227 (DNS-only).
- **Verified:** `/`, `/encounters/3`, `/evals`, `/rules` all 200 over HTTPS with a Let's Encrypt cert; container 300m cap; two eval runs live on `/evals` (rules F1 87.0%, gemini-3.7-flash F1 88.1%, grounded 100%). Free-tier quota: `gemini-3.6-flash` was exhausted mid-eval, so production runs `gemini-3.7-flash`.
