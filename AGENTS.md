# Agents

Instructions for AI coding agents working in this repository.

## Project context

Read [SOURCE.md](SOURCE.md) first — in every chat, before inferring from code or conversation. SOURCE.md is the persistent project record; chat history is not project memory.

When you learn or change durable project facts (stack, architecture, decisions, deferrals, focus), update SOURCE.md. Append to Decisions and Deferred; rewrite Current focus when it shifts. Do not duplicate project facts in chat or in this file.

Prefer SOURCE.md over this file or codebase inference when they conflict.

## Reading SOURCE.md

- Always read **Current focus** and **Overview** first.
- Read other sections only when the task needs them (e.g. **Commands** before run/test work, **Architecture** before large refactors).
- Never infer project facts from chat when the relevant SOURCE section exists.

## Workflow

- Confirm scope before large refactors or new dependencies.
- Match existing patterns in the codebase; read surrounding code before editing.
- Run relevant tests or lint after substantive changes when applicable.

## Code changes

- Minimize diff scope; avoid unrelated edits.
- Preserve existing naming, types, and abstractions unless change is required.
- Add comments only for non-obvious logic.

## Boundaries

<!-- source: boundaries-default -->

**Do:**

- Always use read-only git commands when you need repository state — e.g. `git status`, `git diff`, `git log`, `git show`.
- Always update SOURCE.md when durable project facts change.
- Always ask the user to run builds manually when a build is needed.
- Always use `gh` only for read-only PR review when needed — e.g. `gh pr view`, `gh pr diff`, `gh pr checks`.
- Always stop and report when an approach fails; wait for the user's explicit approval before retrying or trying another approach.

**Do not:**

- Never run write git commands unless the user explicitly asks — includes `commit`, `push`, `tag`, `reset`, `rebase`, and other operations that mutate repository state.
- Never open pull requests unless the user explicitly asks.
- Never use `gh` for write, push, edit, or change actions — includes `gh pr create`, `gh pr merge`, `gh issue create`, and similar mutating commands; always ask the user to run them and hand over the exact command.
- Never run build commands yourself — e.g. `npm run build`, `flutter build`, `make`, `cargo build`, or equivalent; the user runs builds manually.
- Never run Docker build commands yourself — e.g. `docker build`, `docker compose build`; the user runs Docker builds manually.
- Never run database migrations yourself — e.g. `php artisan migrate`, `prisma migrate`, `pnpm db migrate`, `rails db:migrate`, or equivalent; always ask the user to run migrations, including on local environments.
- Never retry, loop, or switch to an alternative approach after a failure without the user's approval.
- Never rely on conversation history for project facts — read and update SOURCE.md instead.
- Never remove or overwrite SOURCE.md entries without reason.

<!-- /source: boundaries-default -->

<!-- Project-specific additions below -->

## Verification

Before finishing, ensure changed behavior is covered by existing tests or manual steps documented in SOURCE.md.
