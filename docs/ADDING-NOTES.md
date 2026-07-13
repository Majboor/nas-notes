# Handover: Adding notes to Cherry (for an AI agent)

**What Cherry is.** A macOS menu-bar app (🍒 Cherry, `~/Applications/Cherry.app`). Each note is a
single Markdown file. There is **no database** — the notes folder *is* the source of truth.

## The one rule

One note = one `.md` file in the notes folder:

```
$NAS_NOTES_DIR   (defaults to  ~/.rpidrive/notes)
```

- **Filename → identity.** `deploy-steps.md` becomes the note's internal name, its Spotlight
  launcher (`Deploy Steps Handover.app`), and its deep link `nasnote://deploy-steps`. Use
  **lowercase-with-hyphens**, no spaces, no `/`.
- **First `# ` line → title.** The first `# Heading` line is the display title. If there's no
  `#` line, the title falls back to the filename.
- **Ordering.** `NAS` and `email` are pinned to the top (if present); everything else is
  alphabetical.

## Add a note

```bash
NOTES="${NAS_NOTES_DIR:-$HOME/.rpidrive/notes}"

cat > "$NOTES/deploy-steps.md" <<'EOF'
# Deploy steps

## Build
1. Pull latest
2. `./Scripts/build.sh`

## Ship
- Tag the release, then `git push --tags`
EOF

# Regenerate the CherryTree doc + Spotlight launcher for the new note:
"$NOTES/rebuild.sh"
```

That's it. Standard Markdown works: `#`/`##`/`###` headings, `- ` bullets, `**bold**`,
`` `code` ``, ` ``` ` fenced blocks, `> ` quotes, `[text](url)` links.

## What each step does / when it's needed

- **Writing the `.md` file is sufficient for the app itself** — Cherry reloads the folder every
  time the popover opens, so a new note shows up on next open with **no restart**.
- **`rebuild.sh` is only needed to refresh the two derived artifacts:** the CherryTree document
  (`NAS.ctd`) and the per-note **Spotlight launcher apps**. Run it after **adding or deleting** a
  note so ⌘-Space `<Title> Handover` works and stale launchers get pruned. It's idempotent and
  safe to run by hand.

## Edit / delete

- **Edit:** overwrite the same `.md` file. (No rebuild needed unless you want the CherryTree copy
  refreshed.)
- **Delete:** `rm "$NOTES/<name>.md"` then `"$NOTES/rebuild.sh"` (the rebuild prunes the orphaned
  Spotlight app).

## Verify

```bash
ls "$NOTES"/*.md                 # confirm the file exists
open "nasnote://deploy-steps"    # opens Cherry focused on that note
```

Or just click 🍒 Cherry in the menu bar — the new note is in the list.

## Don'ts

- Don't put spaces / slashes / `:` in filenames.
- Don't rename `NAS.ctd` or the two helper scripts (`rebuild.sh`, `make-launchers.sh`) in the
  folder — the app and CherryTree export depend on them.
- Credential-bearing notes live in this folder but should **never be committed** to a public repo.
