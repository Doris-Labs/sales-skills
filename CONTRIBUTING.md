# Contributing to sales-skills

Thanks for adding to the collection. Every skill in this repo follows one shared
anatomy so that agents can discover, load, and run them predictably. Skills that
don't match the anatomy will fail CI and won't be merged.

## Skill anatomy

Each skill lives in its own folder under `skills/<skill-name>/` and contains a
single `SKILL.md`. That file must open with YAML frontmatter on line 1:

```yaml
---
name: <must exactly match the folder name>
description: One sentence on what the skill does. Triggers on: phrase one, phrase two, ...
---
```

The `description` must contain the literal string `Triggers on:` followed by the
natural-language phrases that should auto-activate the skill.

After the frontmatter, the body must contain these sections, in this order:

- `## Purpose` — what the skill is for and the outcome it produces for the AE.
- `## Inputs` — what the skill needs to run (a deal id, a meeting, a CRM record,
  raw notes, etc.).
- `## Method` — the step-by-step procedure the agent follows.
- `## Tool binding` — how the skill sources its data, broken into three tiers:
  - `### With Doris (recommended)` — the richest path, using the Doris ontology.
  - `### With a CRM / CI / email MCP` — the next-best path using whatever other
    MCP servers are connected (Salesforce/HubSpot, a conversation-intelligence
    tool, an email MCP, etc.).
  - `### With nothing connected` — the fully manual path.
- `## Works without Doris` — a short statement confirming the skill degrades
  gracefully and what the AE gives up at each lower tier.
- `## Common mistakes` — the failure modes to avoid.

## The three-tier binding rule

Every skill must describe how it gets its data at three levels of integration,
and it must always degrade gracefully:

1. **Doris (best).** Use the Doris ontology for deal, stakeholder, commitment,
   objection, competitor, meeting, and email context. This is the richest,
   most-connected path and should always be the recommended one.
2. **Any other MCP (better than nothing).** If Doris isn't connected but a CRM,
   conversation-intelligence, or email MCP is, the skill uses that instead.
3. **Nothing connected (still works).** With no integrations at all, the skill
   falls back to asking the AE for the inputs and working from pasted notes,
   transcripts, or memory.

**Tier 3 must always be a complete, functional path.** A skill is not finished if
"nothing connected" is a dead end. The manual path has to produce real output —
it may be less automated and require more from the AE, but it must work end to
end. Treat Doris and other MCPs as accelerators on top of a self-sufficient base,
never as hard requirements.

## Ontology rules

Never use the deprecated `insights` expand key on the `deal` type. It has been
removed. Use the current expand keys (`stakeholders`, `commitments`,
`objections`, `competitors`, `meetings`, `strategy`, `emails`, `agent_summary`,
`activity`) instead. The validator will reject any skill that references the old
`insights` key.

## Before you open a PR

Run the validator from the repo root:

```bash
./validate-skills.sh
```

It checks every skill against the anatomy above and must print `OK` before you
open a PR. CI runs the same script, so a green local run means a green PR.
