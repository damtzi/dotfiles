---
description: Generate daily report from git commits and write to Obsidian daily note
subtask: true
---

Analyze git changes for a given day and write a summary to the user's Obsidian daily note.

**Target date argument:** $ARGUMENTS

If `$ARGUMENTS` is empty or blank, target today's date. Otherwise parse the provided date (e.g. `2026-03-03`).

## Git commits for the target date:

!`if [ -n "$ARGUMENTS" ]; then git log --after="$ARGUMENTS 00:00" --before="$ARGUMENTS 23:59" --format="%h %s" --no-merges; else git log --since=midnight --format="%h %s" --no-merges; fi`

## Changed files for the target date:

!`if [ -n "$ARGUMENTS" ]; then FIRST=$(git log --after="$ARGUMENTS 00:00" --before="$ARGUMENTS 23:59" --format=%H --no-merges | tail -1); LAST=$(git log --after="$ARGUMENTS 00:00" --before="$ARGUMENTS 23:59" --format=%H --no-merges | head -1); [ -n "$FIRST" ] && git diff --stat "$FIRST"^.."$LAST" 2>/dev/null; else FIRST=$(git log --since=midnight --format=%H --no-merges | tail -1); [ -n "$FIRST" ] && git diff --stat "$FIRST"^..HEAD 2>/dev/null; fi`

## Current daily note content:

!`obsidian daily:read`

## Daily note template (for reference):

!`obsidian read file="daily.template"`

## Obsidian vault path:

!`obsidian vault info=path`

## Instructions:

1. Determine the target date. If `$ARGUMENTS` was provided, use that date. Otherwise use today.
2. If there are no commits for the target date, tell the user and stop.
3. Infer the project name from the current working directory (e.g. `/Users/me/dev/acme/webapp` -> `Acme`). Use the parent directory or repo name, whichever is more descriptive.
4. Summarize the commits into concise bullet points. Group related commits. Each bullet must be prefixed with `[[ProjectName]]` (double brackets — Obsidian wikilink style).
5. Place ALL bullet points under "Today I made progress on:". Do not use any other section.
6. Determine the daily note file path: `<vault_path>/500 Daily/<YYYY-MM-DD>.md` using the target date.
7. Read the daily note file at that path. If it doesn't exist, create it using the template structure. If sections already have content, merge new bullets without duplicating existing ones.
8. Write the updated daily note file using the Write tool. Preserve the frontmatter and all existing content. Only add to sections — never remove.
9. After writing, run `obsidian read path="500 Daily/<YYYY-MM-DD>.md"` to verify the result and show the user a short summary of what was added.
