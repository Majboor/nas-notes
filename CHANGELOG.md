# Changelog

All notable changes to this project are documented here.
The format is loosely based on [Keep a Changelog](https://keepachangelog.com/).

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

[1.0.0]: https://github.com/Majboor/nas-notes/releases/tag/v1.0.0
