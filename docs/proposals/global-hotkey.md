# Proposal: Global hotkey

## Motivation
Reaching for the menu-bar item is slower than muscle memory. A global shortcut opens the panel from anywhere.

## Proposal
A configurable system-wide hotkey (default ⌥-Space) that toggles the popover; shown/edited in a small
Settings sheet.

## Approach
- Register with `NSEvent.addGlobalMonitorForEvents` (or a Carbon `RegisterEventHotKey` for reliability).
- Toggle `openPopover()` / close. Persist the chosen combo in `UserDefaults`.

## Acceptance criteria
- The hotkey opens/closes the panel from any app.
- The combo is configurable and survives relaunch; no conflict crash if the combo is taken.
