# Roadmap

Future goals for NAS Notes. Each item has a proposal under `docs/proposals/` and is developed on its
own `feature/*` branch, then merged to `main`.

## Now (v1.x)
- [x] Menu-bar popover with All Notes list
- [x] Add / edit / delete notes in-app (writes Markdown files)
- [x] Per-note Spotlight launchers via `nasnote://` URL scheme
- [x] CherryTree export + one-click Copy

## Next (v1.1)
- [ ] **Standalone editor window** — pop the editor out of the popover into a real, resizable
  `NSWindow` so long notes are comfortable to write and keyboard focus is rock-solid.
  → `feature/standalone-editor-window` · [proposal](docs/proposals/standalone-editor-window.md)
- [ ] **Search / quick-filter** — a search field in All Notes to filter by title and body as you type.
  → `feature/note-search` · [proposal](docs/proposals/note-search.md)

## Later (v1.2)
- [ ] **Git-backed notes sync** — optionally back the notes folder with a git repo and auto-commit
  on save, for history + cross-machine sync without a cloud service.
  → `feature/git-backed-notes` · [proposal](docs/proposals/git-backed-notes.md)
- [ ] **Global hotkey** — a configurable shortcut (e.g. ⌥-Space) to toggle the panel from anywhere.
  → `feature/global-hotkey` · [proposal](docs/proposals/global-hotkey.md)

## Ideas (unscheduled)
- Pinned / reorderable notes and folders/tags.
- Live Markdown preview split-view while editing.
- Per-note custom icon/emoji in the list and in Spotlight.
- Encrypted notes (for the credential-bearing ones) via the Keychain.
- Export a note as a shareable link straight from the app.
