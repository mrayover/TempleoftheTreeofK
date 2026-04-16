# Phase 3 — Grapple Attack Placeholder Motion Layer

## Summary
Phase 3 added a **state-driven placeholder motion layer** for the grapple attack system in `player.gd`.

This phase did **not** redesign input parsing, state ownership, traversal grapple behavior, or final combat timing. It only made the grapple weapon's motion **visibly distinct by attack state** so the player can read what the weapon is doing.

---

## What the file was doing before
Before this change, the grapple attack visual layer was structurally present but visually ambiguous:

- `local_start` was anchored correctly
- `local_end` always extended straight forward
- all grapple attack states visually collapsed into the same generic line behavior

Result:
- `ATTACK_EXTEND`, `ATTACK_DROP`, `ATTACK_RESET_RECALL`, `ATTACK_CHARGE`, `ATTACK_HEAVY_RELEASE`, and combo states all read too similarly
- the state machine could function internally, but the player could not clearly read state changes from the weapon motion

---

## What was changed
Only the grapple attack visual/motion block was changed.

The old single `local_end` assignment was replaced with a **match-based state-driven motion block**.

A new `base_end` position was introduced and `local_end` now changes depending on `grapple_attack_state`.

This keeps the implementation:
- placeholder-friendly
- state-owned
- easy to extend later for timing, hitboxes, and polish

---

## State-by-state solutions implemented

### `ATTACK_EXTEND`
- kept as the normal forward extension
- serves as the baseline readable attack pose

### `ATTACK_HIT_CONFIRM`
- currently held on the normal forward extension
- gives this state a dedicated motion hook without overbuilding behavior yet

### `ATTACK_DROP`
- tip now visibly drops downward instead of reading like a normal retract
- this creates a readable “window open” state

### `ATTACK_RESET_RECALL`
- grapple now snaps inward using a shortened interpolated position
- reads as a deliberate reset/recall rather than a second attack
- leaves the weapon in a clean ready-state visual

### `ATTACK_COMBO_2`
- added placeholder lateral/wave motion using a sine offset
- gives combo 2 a visibly different read from standard extension

### `ATTACK_COMBO_3`
- added a downward-strike style endpoint offset
- gives combo 3 a separate, more vertical/dropping visual identity

### `ATTACK_CHARGE`
- grapple now visually pulls inward and holds short
- reads as stored tension instead of retract/reset

### `ATTACK_HEAVY_RELEASE`
- added exaggerated forward overshoot
- reads as a stronger discharge rather than a standard attack extension

---

## Core implementation pattern
The visual block now follows this pattern:

1. compute `local_start`
2. compute `base_end`
3. initialize `local_end = base_end`
4. override `local_end` by `grapple_attack_state`
5. derive `direction` and `distance` from the resulting state-owned endpoint

This means the rope/head visual stays on the existing pipeline, but the endpoint is now state-readable.

---

## Scope preserved
The following were intentionally **not changed**:

- Phase 1 state machine ownership
- Phase 2 input parsing / press-hold-release logic
- traversal grapple behavior
- hitbox timing
- damage windows
- final combo gameplay logic
- final charge/heavy combat logic
- body animation polish

This phase stayed tightly scoped to **placeholder weapon motion only**.

---

## Result
Phase 3 now gives the grapple attack system readable placeholder motion.

The player can visually distinguish:
- normal extend
- drop state
- reset recall
- combo 2
- combo 3
- charge hold
- heavy release

This makes the system easier to understand in play and creates a cleaner foundation for later phases involving:
- combo timing
- hitbox timing
- hit confirmation polish
- final charge/heavy gameplay
- animation sync

---

## Success criteria met
- state-driven weapon motion added
- drop visually distinct from retract
- reset recall visually distinct from attack extension
- combo 2 and combo 3 have separate placeholder motion ideas
- charge and heavy release no longer visually collapse into reset/retract
- input/state logic preserved
- traversal grapple unchanged
- implementation remains placeholder-simple and extendable
