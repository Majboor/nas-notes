# Proposal: Git-backed notes sync

## Motivation
Notes are plain `.md` files. Backing the folder with git gives free history, diffs, and cross-machine sync
without a proprietary cloud.

## Proposal
Optional (off by default): if `$NAS_NOTES_DIR` is a git repo, auto-commit on save/delete and offer pull/push.

## Approach
- Detect `.git` in the notes dir. After writing a file on `save`/`delete`, run `git add -A && git commit`.
- Menu action **Sync now** → `git pull --rebase && git push`. Surface conflicts; never auto-resolve destructively.

## Acceptance criteria
- Each save produces a commit when the notes dir is a repo.
- **Sync now** round-trips to a remote; inert when not a repo.
