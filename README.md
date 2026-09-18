# Abstractor

A medical coding worklist where an AI agent proposes ICD-10-CM and CPT codes for a clinical
note, a human coder reviews every proposal inline, and a rules engine keeps a wrong claim from
ever being finalized.

Live: https://abstractor.levelbrook.com

Rails 8.1 · Hotwire (Turbo Frames, Turbo Streams, morphing) · PostgreSQL · Gemini via a response
schema, with a deterministic rules coder as the offline baseline.

## What it does

1. **Encounters** enter a worklist with a synthetic clinical note.
2. **The coding agent** reads the note and proposes codes. It may only pick from the code
   dictionary, and every proposal carries a *verbatim quote* from the note plus a one-line
   coding rationale. Proposals stream into the review pane over Turbo Streams as they land.
3. **The grounding gate** looks each quote up in the note. Found: the proposal is grounded and
   the quote is highlighted in the note. Not found: the proposal is kept (nothing is silently
   dropped) but flagged *unverified* and its confidence is halved, so a confident hallucination
   can never look like a confident citation.
4. **A coder reviews**: accept, reject, accept an E/M with modifier 25, or add a code the agent
   missed. Each action is a Turbo Frame swap; the worklist and the issues panel refresh in every
   open tab. The agent never accepts anything itself, and re-running it never touches a code a
   human has already reviewed.
5. **The rules engine** runs on every change and names the rule behind each issue:

   | rule | severity | catches |
   |---|---|---|
   | `unreviewed` | block | an agent proposal nobody has accepted or rejected |
   | `header-code` | block | a category header (E11) accepted instead of a billable code (E11.9) |
   | `excludes1` | block | two diagnoses ICD-10-CM says cannot be reported together (prefix-matched, so E11 vs E10 covers E11.65 vs E10.9) |
   | `no-diagnosis` | block | procedure codes with nothing to point at |
   | `multiple-em` | block | two E/M codes on one encounter |
   | `modifier-25` | block | an E/M on the same day as a procedure without modifier 25 |
   | `symptom-integral` | warn | an R-code next to a definitive diagnosis |
   | `unverified-evidence` | warn | an accepted code whose quote is not in the note |

6. **Finalize** is exactly once. The encounter row is locked, the status is re-read under the
   lock, the rules run again, and only then is a claim number issued. Eight concurrent
   finalizers produce one claim and one `encounter.finalized` event; the test proves it.
7. **Every action is an event** in an append-only log (rows cannot be updated or destroyed).
   The audit trail under each note is derived from it.

## Evals

`/evals` scores any coder against 16 labelled notes on the **code set**, not on prose: a
proposal is correct only if the exact code is in the gold set. Precision, recall and F1 are
reported alongside the grounded percentage, because being right without being able to quote
the note is its own failure. The rules coder is the floor (recall 1.0, precision about 0.75:
it over-codes negated symptoms like "no fever"); the model has to beat it. A case whose model
call fails after retries scores zero and carries the error, so one 429 cannot abort the run.

First live run (2026-09-17, free-tier Gemini, 16 cases): rules coder precision 77.1% / recall
100% / F1 87.0%; `gemini-3.7-flash` precision 100% / recall 78.7% / F1 88.1% / grounded 100%,
where every miss is one of four cases the free tier answered with a 429 and the page says so.

## Running it

```
bin/rails db:setup      # seeds the dictionary, Excludes1 pairs, 9 encounters, 16 eval cases
bin/rails test          # 17 tests / 63 assertions, including the 8-thread finalize race
bin/rails server
GEMINI_API_KEY=... bin/rails server   # switches the agent from the rules coder to Gemini
```

Everything is synthetic: fabricated patient references, invented notes, and an illustrative
subset of real ICD-10-CM / CPT conventions. It is not a coding reference.

## Layout

- `app/services/coding_agent.rb` – runs a coder, applies the grounding gate, writes reviewable rows
- `app/services/coders/gemini_coder.rb` – schema-constrained model call, dictionary-restricted
- `app/services/coders/rule_coder.rb` – deterministic vocabulary baseline
- `app/services/claim_validator.rb` – the rules above
- `app/services/eval_harness.rb` – precision / recall / F1 / grounded on the labelled set
- `app/models/encounter.rb` – `finalize!` and the evidence-span resolver
- `test/` – grounding gate, validator rules, exactly-once finalize, eval arithmetic
