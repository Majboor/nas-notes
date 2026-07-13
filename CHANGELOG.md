# Changelog

All notable changes to this project are documented here.
The format is loosely based on [Keep a Changelog](https://keepachangelog.com/).

## [1.4.0]

### Changed
- **Rebranded to Cherry Note Taker.** The menu-bar item is now **🍒 Cherry**, the app bundle is
  `Cherry.app`, and the repository is `cherry-note-taker`. Internal identifiers
  (`com.hico.nasnotes`, the `nasnote://` scheme, `NAS_NOTES_DIR`) are unchanged for compatibility.
- Screenshots + demo GIF regenerated with the new branding.

## [1.3.0]

### Added
- Clipboard **de-duplication**: re-copying the same content no longer stacks — the existing card gains a
  **×N** counter and moves to the top (images de-duped by content hash).
- A rich README with **real UI screenshots** and a demo **GIF**, plus `Scripts/snapshot.swift` +
  `Scripts/screenshots.sh` to regenerate them from the actual UI.

## [1.2.0]

### Added
- Clipboard: more data types — **emails, errors/stack traces, colors (with swatch), IP addresses,
  phone numbers** — on top of links/code/paths/images/videos/files/text.
- Clipboard **search** field (matches preview, filename, path, language, type).
- Clipboard **favourites**: ★ any clip; a Favourites filter; favourites are protected from the history cap.
- **In-app toast** on copy-back ("Now copied · <type> · <preview>") in the app's own theme.
- Existing string clips are **re-classified on launch**, so items captured before a detector existed
  (e.g. emails, errors) get re-sorted into the right category.

## [1.1.0]

### Added
- **Clipboard history** — a background pasteboard watcher captures everything you copy into an
  on-disk store (`~/Library/Application Support/NASNotes/clips`). A new **Clipboard** view shows
  entries **grouped by date** and filterable by type: **Links, Code, Paths, Images, Videos, Files, Text**.
  - Code is **auto-classified by language** (swift, python, javascript, bash, json, sql, html, …).
  - File **paths are auto-detected** and labeled.
  - Images/photos are thumbnailed inline; files/videos show name + path.
  - Click an entry to **copy it back**; per-item delete and **Clear all**.
  - Password-manager clips marked concealed/transient are **ignored**; history is capped at 300 items.

## [1.0.0]
First public release.

### Added
- Menu-bar status-item app (`LSUIElement`) with a `WKWebView` popover.
- **All Notes** home screen listing every `.md` note with a title + preview.
- Read view with Markdown rendering (headings, code fences, lists, blockquotes, links, inline code).
- **Add / Edit / Delete** notes in-app; edits are written back to the Markdown files atomically.
- `nasnote://<name>` URL scheme; **per-note Spotlight launcher apps** built by `Scripts/make-launchers.sh`.
- **CherryTree** export (`.ctd`) and one-click **Copy** of a whole note.
- `Scripts/rebuild.sh` regenerates the CherryTree doc and prunes/rebuilds launchers after any change.
- Configurable notes store via `NAS_NOTES_DIR` (default `~/.rpidrive/notes`).
- Native macOS look with automatic light/dark support.

[1.0.0]: https://github.com/Majboor/cherry-note-taker/releases/tag/v1.0.0
