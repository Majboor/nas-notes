# Proposal: Search / quick-filter in All Notes

## Motivation
As the number of notes grows, scrolling is slow. A quick filter keeps the app usable with dozens of notes.

## Proposal
A search field pinned atop **All Notes** that filters rows as you type, matching note **title** and **body**;
show a "no results" state.

## Approach
- Front-end only: the notes array already lives in the WebView. Add an `<input>` and filter rows on `input`.
- Focus the field when the popover opens; ⌘F focuses, Esc clears.
- Later: fuzzy matching + match snippets in the preview line.

## Acceptance criteria
- Typing filters live with no perceptible lag for 100+ notes.
- Clearing restores the full list; works in light and dark mode.
