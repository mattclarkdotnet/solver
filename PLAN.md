# Plan

## Roadmap alignment
- This plan delivers the current `ROADMAP.md` `Now` item by replacing the current top word-list control area with a bottom status bar that exposes the active word-list choice and a hamburger menu for secondary app actions.

## Objective
- Ship a bottom status bar that keeps the current word-list choice visible and tappable while adding a compact hamburger menu with `Preferences`, `Help`, and `About`, without disturbing the active solver workflow.

## Assumptions
- The bottom status bar should be app-level chrome that stays visible while the active tool content scrolls.
- The visible word-list choice in the status bar should remain directly tappable so users can switch lists without leaving the current tool.
- The hamburger menu is part of the same bottom bar and should expose `Preferences`, `Help`, and `About` as secondary actions only; it should not read like another solver tool.
- `Preferences` should reuse or extend the existing in-app preferences direction rather than bouncing the user into iOS Settings.
- `Help` and `About` can be lightweight in-app surfaces for this slice; they do not need to become full standalone features unless the implementation naturally requires it.

## Scenario mapping
- `See the active word list at a glance`: GIVEN the user is using any implemented solver tool, WHEN the screen is visible, THEN the bottom status bar shows the currently selected bundled word list.
- `Change word lists from the bottom bar`: GIVEN the user is in an implemented tool, WHEN they tap the displayed word-list choice in the bottom status bar, THEN they can switch groups without leaving the current tool.
- `Open the hamburger menu`: GIVEN the user is on any implemented screen, WHEN they tap the hamburger control in the bottom status bar, THEN they can access `Preferences`, `Help`, and `About`.
- `Keep active-tool context while using secondary chrome`: GIVEN the user opens the word-list control or hamburger menu, WHEN they dismiss it or choose a secondary action, THEN the current solver tool and shared input remain coherent.
- `Offline operation`: GIVEN the device has no network connectivity, WHEN the user interacts with the bottom status bar, THEN the app behaves normally using only local UI and bundled data.

## Exit criteria
- Replace the current top word-list control with a bottom status bar that remains visible as app-level chrome.
- Show the active word-list choice in that bottom bar and keep it directly tappable for in-place switching.
- Add a hamburger menu to the same bottom bar with `Preferences`, `Help`, and `About`.
- Keep the current solver tool selected and the shared input state intact while interacting with the bottom bar.
- Update automated tests and the documentation set to cover the new status-bar layout, the moved word-list control, and the hamburger-menu actions.

## Promotion rule
- Promote this plan when the bottom status bar replaces the current word-list control, the active word list is visible and tappable there, the hamburger menu exposes `Preferences`, `Help`, and `About` without disrupting the active tool, and the behavior is verified and documented, then move that roadmap item to `Completed` and replace `PLAN.md` with a new plan for the next `Later` item.
