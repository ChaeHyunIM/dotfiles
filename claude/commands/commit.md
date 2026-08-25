---
allowed-tools: Bash(git add:*), Bash(git status:*), Bash(git commit:*), Bash(git diff:*), Bash(git branch:*), Bash(git log:*)
description: 변경 범위를 검토한 뒤 한국어 Conventional Commit 메시지로 하나의 로컬 커밋을 만듭니다.
model: haiku
---

## Context

- Current git status: !`git status`
- Current git diff (staged and unstaged changes): !`git diff HEAD`
- Current branch: !`git branch --show-current`
- Recent commits: !`git log --oneline -10`

## Your task

Review the current changes and create one cohesive local commit.

### Step 1: Verify the commit scope

- Follow the applicable repository instructions in `CLAUDE.md` and `AGENTS.md`, including required pre-commit checks.
- Include only changes that belong to the requested work.
- Preserve unrelated changes and changes made by the user or another session.
- If you cannot determine whether a change belongs in the commit, ask the user before staging it.
- Do not push, amend, reset, or rebase unless the user explicitly requests it.
- Let every Git hook configured by the repository run normally. Never use `--no-verify`, environment variables, or Git configuration to disable or bypass hooks. If a hook fails or modifies files, review the result, make any required fixes, restage the intended changes, and retry the commit.

### Step 2: Write the commit message

Use a Korean Conventional Commit message:

- Format: `type(scope): description`; omit the scope when it adds no useful information.
- Type: `feat`, `fix`, `refactor`, `style`, `chore`, `docs`, `test`, or another established repository type.
- Scope: use the repository's existing domain, package, or application name. Do not invent a scope.
- Description: write an imperative Korean phrase ending in `~함`.
- Add Claude's standard `Co-Authored-By` trailer.

### Step 3: Commit and verify

- Stage only the intended files and create a single commit without opening an interactive editor.
- Confirm the new commit hash and title.
- Check `git status` again and report any changes left uncommitted.
