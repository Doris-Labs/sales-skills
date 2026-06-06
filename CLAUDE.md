# CLAUDE.md

This repo is `sales-skills` — a collection of Claude skills for Account
Executives. When working in this repo, start by reading `AGENTS.md`: it explains
how the skills compose (the `sales-context` shared layer, auto-triggering on
`Triggers on:` phrases, and the three graceful-degradation binding tiers of
Doris → other MCP → nothing connected).

Before committing or opening a PR, run the validator at the repo root:

```bash
./validate-skills.sh
```

It enforces the skill anatomy on every `skills/*/SKILL.md`. Authoring conventions
and the full anatomy are documented in `CONTRIBUTING.md`.

This repo is MIT licensed (see `LICENSE`). All PRs must pass CI, which runs
`validate-skills.sh` — a green local run means a green PR.
