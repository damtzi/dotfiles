#!/usr/bin/env bash
# Claude Code status line.
# Shows: model · effort · context-% bar · tokens · cost · 5h/7d rate limits.
# All data comes from the harness JSON on stdin (see code.claude.com/docs/en/statusline).

input=$(cat)

python3 - "$input" <<'PY'
import json, sys

data = json.loads(sys.argv[1])

# ANSI
RESET = "\033[0m"; DIM = "\033[2m"; CYAN = "\033[36m"; MAGENTA = "\033[35m"
GREEN = "\033[32m"; YELLOW = "\033[33m"; RED = "\033[31m"

def pct_color(p):
    if p < 60: return GREEN
    if p < 85: return YELLOW
    return RED

def fmt_tokens(n):
    return f"{n/1000:.1f}k" if n >= 1000 else str(n)

model = data.get("model", {}).get("display_name") or data.get("model", {}).get("id") or "Claude"

cw = data.get("context_window") or {}
size = cw.get("context_window_size") or 200_000
tokens = cw.get("total_input_tokens") or 0
pct = cw.get("used_percentage")
if pct is None:
    pct = (tokens / size * 100) if size else 0

# Progress bar
WIDTH = 16
filled = int(round(pct / 100 * WIDTH))
bar = "█" * filled + "░" * (WIDTH - filled)

parts = [f"{CYAN}{model}{RESET}"]

effort = (data.get("effort") or {}).get("level")
if effort:
    parts.append(f"{MAGENTA}{effort}{RESET}")

parts.append(f"{pct_color(pct)}[{bar}]{RESET} {pct:.0f}%")
parts.append(f"{DIM}{fmt_tokens(tokens)} tok{RESET}")

cost = (data.get("cost") or {}).get("total_cost_usd")
if isinstance(cost, (int, float)) and cost > 0:
    parts.append(f"{DIM}${cost:.2f}{RESET}")

rl = data.get("rate_limits") or {}
rl_bits = []
for key, label in (("five_hour", "5h"), ("seven_day", "7d")):
    win = rl.get(key) or {}
    used = win.get("used_percentage")
    if used is not None:
        rl_bits.append(f"{pct_color(used)}{label} {used:.0f}%{RESET}")
if rl_bits:
    parts.append("  ".join(rl_bits))

print(f"  {DIM}·{RESET}  ".join(parts))
PY
