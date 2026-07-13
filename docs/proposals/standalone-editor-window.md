# Proposal: Standalone editor window

## Motivation
Editing happens inside the menu-bar popover today. Popovers are transient (they close on
focus loss) and cramped for long notes. Writing a multi-paragraph note is uncomfortable and
keyboard focus can feel fragile.

## Proposal
When the user taps **Edit** (or **+**), open the editor in a real, resizable `NSWindow`
instead of the popover:
- Standard title bar with the note title; **Save** / **Cancel** buttons.
- Remember window size/position between sessions (`NSWindow.frameAutosaveName`).
- Keep the popover for *reading*; editing gets the window.
- Optional: live Markdown preview split-view (see the preview idea in ROADMAP).

## Approach
- Add an `EditorWindowController` (NSWindowController) hosting an `NSTextView`.
- Route `openEdit()` / `addNote()` to open/raise the window; on Save reuse the existing
  `save` bridge message, then refresh the popover list.

## Acceptance criteria
- Editing a note opens a resizable window that survives clicking elsewhere.
- Save writes the `.md` and updates the list + Spotlight launchers.
- Window frame persists across launches.
