# Plan

## Roadmap alignment
- This plan delivers the current `ROADMAP.md` `Now` item by keeping feature promotion on hold while the roadmap remains sliced into approved single-functionality items.

## Objective
- Keep planning artifacts internally consistent after completion of the current implementation slice so the next promoted item can be chosen deliberately rather than implicitly.

## Assumptions
- Solver is an offline-only app, so every shipped feature in this plan must work entirely from bundled or on-device data.
- The just-completed crossword-tab refinement is accepted and can move to `Completed`.
- The developer does not want any feature item promoted into `Now` yet.
- `ROADMAP.md` still needs one `Now` item and one `Next` item even during a holding state because of the repository rules in `AGENTS.md`.
- `Later` items should each describe exactly one piece of functionality so future promotion decisions stay narrow and explicit.

## Scenario mapping
- `Completion bookkeeping`: GIVEN the current crossword-tab item is finished, WHEN the roadmap is updated, THEN that item appears in `Completed` and no longer remains in an active section.
- `No implicit promotion`: GIVEN the developer does not want a new implementation slice started yet, WHEN the roadmap is rewritten, THEN no feature item is advanced into `Now`.
- `Single-slice backlog`: GIVEN future work remains in `Later`, WHEN each item is reviewed, THEN each entry describes one piece of functionality rather than a bundled set of changes.
- `Plan consistency`: GIVEN the roadmap changes, WHEN `PLAN.md` is replaced, THEN it matches the new holding state instead of describing already-finished work.

## Exit criteria
- Move the completed crossword-tab refinement into `Completed` at the top of the list.
- Replace the old feature-oriented `Now` and `Next` entries with holding items that do not implicitly reprioritize implementation work.
- Move the former `Next` feature item into `Later` rather than promoting it.
- Rewrite every `Later` entry so each item contains only one piece of functionality.
- Replace `PLAN.md` so it accurately describes the holding state created by the updated roadmap.

## Promotion rule
- Promote this plan when the developer chooses a specific single-functionality backlog item to move into `Now`, then replace this holding plan with an implementation plan for that chosen item.
