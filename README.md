# NAS Notes

A **super-light macOS menu-bar notes app** in ~300 lines of Swift. It lives in your menu bar,
keeps a set of plain-Markdown notes, and gives each note its own **Spotlight launcher** so you can
jump straight to it with ⌘-Space. Built originally as the "handover notes" panel for a home-NAS
project, but it's a general, dependency-free notes app.

<!-- add docs/screenshot.png -->

## Features

- **Menu-bar popover** — click the menu-bar item for an **All Notes** list; open any note to read it.
- **Native macOS UI** — SF font, segmented navigation, light/dark aware. No web frameworks bundled;
  the UI is a single inline `WKWebView` document.
- **Add / edit / delete in-app** — write Markdown, hit **Save**, it writes straight back to the `.md`.
- **Markdown rendering** — headings, code fences, lists, blockquotes, links, inline code — no external libs.
- **Spotlight launchers** — every note gets a tiny `<Title> Handover.app`; ⌘-Space → type the note name →
  the panel opens focused on it (via a `nasnote://<name>` URL scheme).
- **CherryTree export** — one click opens all notes as a CherryTree document.
- **Copy** — copy a whole note (e.g. a prompt) to the clipboard in one click.
- **Clipboard history** — a built-in clipboard manager: everything you copy is captured and shown
  **grouped by date**, filterable by type — **Links · Code · Paths · Images · Videos · Files · Text**.
  Code is **auto-labeled with its language** and file **paths are auto-detected**. Click any entry to
  copy it back. Password-manager clips (concealed/transient) are ignored. Clear anytime.
- **Plain files, no lock-in** — notes are just `.md` files in a folder you control.

## Notes store

Notes are `.md` files in a directory chosen by the `NAS_NOTES_DIR` environment variable
(default `~/.rpidrive/notes`). The first `# Heading` line of each file becomes the note's title.

## Install

Requirements: macOS 11+, Xcode command-line tools (`swiftc`). CherryTree is optional
(`brew install --cask cherry-tree` or `brew install cherrytree`) for the export button.

```bash
git clone https://github.com/Majboor/nas-notes.git
cd nas-notes
./Scripts/build.sh            # compiles + installs ~/Applications/NAS Notes.app
./Scripts/install-login-item.sh   # (optional) start it at login
```

`build.sh` seeds the notes folder with `examples/welcome.md` if it's empty, then launches the app —
look for the **note icon** in your menu bar.

## Usage

| Action | How |
|--------|-----|
| Browse notes | Click the menu-bar item → **All Notes** |
| Read a note | Click a row |
| New note | **+** (top-right of All Notes) |
| Edit | Open a note → **Edit** → **Save** |
| Delete | Edit mode → **Delete note** |
| Copy a note | Note view → **Copy** |
| Open in CherryTree | Note view → **CherryTree** |
| Jump to a note from anywhere | ⌘-Space → type `"<Note> Handover"` |

After adding/removing notes, the app auto-runs `Scripts/rebuild.sh` to refresh the CherryTree doc
and the Spotlight launchers. You can also run it by hand.

## Project layout

```
Sources/main.swift      # menu-bar app, popover, file I/O, URL scheme
Sources/html.swift      # the UI (HTML/CSS/JS) as one inline template + Markdown renderer
Scripts/build.sh        # compile + bundle + install the .app
Scripts/install-login-item.sh
Scripts/make-launchers.sh   # build/prune the per-note Spotlight apps
Scripts/rebuild.sh          # regenerate CherryTree doc + launchers
examples/welcome.md     # sample note
```

## Roadmap

See [ROADMAP.md](ROADMAP.md). Work happens on `feature/*` branches.

## License

MIT — see [LICENSE](LICENSE).
