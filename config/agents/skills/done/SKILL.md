---
name: done
description: Completes finished feature work by reviewing changes, creating atomic conventional commits, rebasing onto the default branch, opening a PR or merging when safe, closing related issues, and cleaning up worktrees. Use when the user says work is done, asks to finish a branch, merge a worktree, prepare a PR, or clean up completed work.
---

# Done

Finish the current unit of work safely.

## Workflow

1. Inspect repository state:
   - current branch
   - whether this checkout is a git worktree
   - default branch from `origin/HEAD`, GitHub, or fallback to `main`/`master`
   - unstaged/staged/untracked changes
   - related GitHub issues or Linear tickets mentioned in branch names, commits, or code

2. Review uncommitted changes and propose an atomic commit plan.
   - Use conventional commits.
   - If all changes form one coherent unit, propose one commit.
   - If not, propose multiple commits.
   - Ask for confirmation before creating commits.

3. Commit approved changes.

4. Sync with default branch:
   - fetch remote
   - rebase current branch onto default branch
   - if conflicts occur, resolve carefully and explain the resolution
   - ask before force-pushing after a rebase

5. Run project checks:
   - tests
   - lint
   - typecheck
   - build, if applicable

6. Decide delivery path:
   - Prefer opening a PR.
   - Direct merge into default branch only if repo policy clearly allows it or the user explicitly approves.
   - Use `gh` when available.
   - Include issue-closing keywords only when appropriate.

7. Close related GitHub issues or Linear tickets only after PR merge or confirmed direct merge.
   - Ask before closing tickets unless the PR merge clearly auto-closes them.

8. Clean up:
   - delete local/remote feature branches only after merge confirmation
   - remove git worktree only after confirmation
   - leave the repository clean

## Safety rules

Always ask before:
- creating commits
- rebasing
- force-pushing
- merging to default branch
- closing issues/tickets
- deleting branches
- deleting worktrees

Never discard user changes without explicit approval.
