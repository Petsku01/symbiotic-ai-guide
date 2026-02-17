# Status Sync Policy

## Purpose

Prevent status drift between public release notes and roadmap tracking.

## Rule (mandatory for shipped fixes)

When a fix is shipped (merged to `main` and intended for users), update **both**:

1. `CHANGELOG.md`
2. `docs/roadmap/ISSUE-STACK.md`

Do not update one without the other.

## Minimum required update

For each shipped fix:

- `CHANGELOG.md`: add a concise user-facing note under the correct date/version section.
- `ISSUE-STACK.md`: mark the related issue status change (for example: Open → In Progress → Done) and include a short resolution note.

## PR expectations

PRs that ship fixes must include:

- A changelog entry reference.
- The corresponding issue stack status update.

This is enforced in the PR checklist and docs validation checks.
