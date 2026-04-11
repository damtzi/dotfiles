---
description: Generate weekly report from Obsidian daily notes
subtask: true
---

Generate a concise weekly report in Polish based on your Obsidian daily notes.

**Required week start date:** $ARGUMENTS

You must provide the Monday date (format: YYYY-MM-DD). The command will read that day plus 4 consecutive days (Tue, Wed, Thu, Fri) and generate a weekly report.

## Obsidian vault path:

!`obsidian vault info=path`

## Target week dates:

!`echo "Monday: $ARGUMENTS"; echo "Tuesday: $(date -j -f "%Y-%m-%d" "$ARGUMENTS" -v+1d +%Y-%m-%d)"; echo "Wednesday: $(date -j -f "%Y-%m-%d" "$ARGUMENTS" -v+2d +%Y-%m-%d)"; echo "Thursday: $(date -j -f "%Y-%m-%d" "$ARGUMENTS" -v+3d +%Y-%m-%d)"; echo "Friday: $(date -j -f "%Y-%m-%d" "$ARGUMENTS" -v+4d +%Y-%m-%d)"`

## Instructions:

1. The user MUST provide a Monday date in YYYY-MM-DD format as the argument. If no argument is provided, stop and inform the user.
2. Calculate the target week dates: Monday (provided) + 4 days for Friday.
3. For each day from Monday to Friday, check if the daily note exists at: `<vault_path>/500 Daily/YYYY-MM-DD.md`
4. Extract ONLY the content under "Today I made progress on:" that contains `[[premium-platform]]` or `[[d-connect-main]]`.
5. Generate a **concise** weekly report in **Polish** with the following structure:

```
# Raport tygodniowy <MONDAY_DATE> - <FRIDAY_DATE>

## Postęp w pracy
- [[premium-platform]] [Polish description, one line only]
```

6. Merge all items into a single bullet list under "Postęp w pracy". Keep it concise (few bullet points, max 1-2 lines per bullet). Summarize related commits.
7. Each bullet point must maintain the `[[premium-platform]]` or `[[d-connect-main]]` wikilink, depending on the project.
8. Create the output file at: `<vault_path>/400 Work/402 OKE/Weekly/<MONDAY_DATE>-weekly-report.md`
9. Write the file using the Write tool.
10. After writing, show the user the path to the created file.
