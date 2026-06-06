# Sales Skills Repo — Design Spec

**Date:** 2026-06-06
**Status:** Approved for planning
**Owner:** Frazer

## Summary

A standalone, open-source repository of **30 Claude skills for Account Executives**,
modeled on the marketing-skills repo (`coreyhaines31/marketingskills`). The skills
cover the AE's full workflow — prospecting, discovery, deal execution, qualification,
forecasting, and artifacts. Built as a **PLG distribution lever**: AEs install the
repo to make their AI coding agent (Claude Code, Claude cowork, Cursor) good at
selling. Every skill is fully functional on its own, gets sharper when a stack MCP is
connected, and is sharpest with Doris (`mcp.meetdoris.com`) — the reference
integration.

The repo is built **private**, then flipped **public** at launch.

## Goals

- Give AEs a genuinely excellent, tool-agnostic library of sales skills.
- Make the repo a top-of-funnel growth channel for Doris (the marketing-repo model).
- Showcase exactly what Doris does (conversation intelligence → pipeline) by binding
  skills to the real ontology, so the "with Doris" experience is visibly better.
- Keep every skill **complete without any tool** — the methodology never depends on an
  integration. Graceful degradation is a headline feature, not fine print.

## Non-Goals

- Not a Doris product-docs repo. Skills are not "how to operate Doris."
- Not thin MCP API wrappers. MCPs are a capability skills *consume*, not the taxonomy.
- Not building all 30 in one pass without a consistency contract (see Build Approach).
- No backend/app code changes in the Doris monorepo. This is a separate repo.

## Persona

The primary user is an **Account Executive working their pipeline with an AI agent**
at their side (Claude cowork / Claude Code / Cursor). Skills map to the AE's actual
daily job, not to a tool's API surface.

## Design Posture: "Doris as the reference implementation" (Posture B)

Skills are **tool-agnostic in their methodology** and name Doris **first and as
recommended** in a dedicated tool-binding section, with CRM / conversation-intelligence
/ email MCPs and a manual path as first-class fallbacks. The repo reads as: *by the
Doris team, works great with Doris, works fine without.*

- An AE with **zero Doris account** gets a complete, good skill from the methodology
  alone. (PLG reach.)
- The **"With Doris (recommended)"** block is where the pull lives: concretely better
  (real extracted commitments/objections/risks vs. re-derived guesses) and it teaches
  what Doris is *for* without a pitch.

## Repo Structure

```
sales-skills/                    # repo name TBD: doris-sales-skills | salesskills
├── .claude-plugin/              # plugin manifest so it installs as a Claude plugin
├── .github/                     # CI: run skill validation on PRs
│   └── workflows/validate.yml
├── skills/                      # 30 skills, one folder each
│   └── <skill-name>/SKILL.md
├── AGENTS.md                    # how the skills work together (for agents)
├── CLAUDE.md                    # repo conventions
├── CONTRIBUTING.md              # how to add/improve a skill
├── LICENSE                      # MIT
├── README.md                    # purpose, install, tiered "with/without Doris" story, skill index
├── VERSIONS.md
└── validate-skills.sh           # frontmatter/structure linter
```

## Skill Anatomy (every one of the 30 follows this)

1. **Frontmatter** — `name` + `description` ending with explicit `Triggers on:` phrases
   so agents auto-invoke.
2. **Purpose** — one paragraph: what artifact/outcome it produces.
3. **Inputs you need.**
4. **Method** — the actual expertise: frameworks, templates, rules, worked examples.
   This is the bulk of the file ("as detailed as we can").
5. **Tool binding** — three tiers, always in this order:
   - **With Doris (recommended)** — real `mcp.meetdoris.com` calls + expand keys.
   - **With a CRM / CI / email MCP** — generic, brand-agnostic.
   - **With nothing connected** — fully functional manual path.
6. **Works without Doris** — one explicit line restating the Tier-3 behavior.
7. **Common mistakes / quality bar.**

**Default qualification framework = MEDDPICC** (maps onto Doris's
commitments/champions/objections/competitors slots and the live `meddpicc` expand key).
Skills stay framework-aware and name BANT/SPICED alternatives where relevant.

## The 30 Skills

**Foundation (1):** `sales-context` — the central context skill every other skill
references first (AE ICP, deal sizes, sales motion, which MCPs are connected; Doris
registers itself here once).

**Prospecting & outbound (5):** `account-research` · `prospecting` · `cold-email` ·
`sequence-writing` · `social-selling`

**Pre-call & discovery (4):** `meeting-prep` · `discovery-planning` · `discovery-call` ·
`stakeholder-mapping`

**Deal execution (6):** `demo-strategy` · `post-call-followup` · `objection-handling` ·
`mutual-action-plan` · `competitive-battlecard` · `negotiation`

**Qualification & deal health (5):** `meddpicc-qualification` · `deal-risk-review` ·
`champion-building` · `multithreading` · `closing-plan`

**Pipeline & forecast (4):** `deal-review-prep` · `forecast-hygiene` · `pipeline-review` ·
`crm-hygiene`

**Expansion & retention (2):** `expansion-upsell` · `renewal-churn-save`

**Artifacts (3):** `business-case-roi` · `proposal` · `executive-briefing`

= **30 total.**

## Doris Binding Contract (verified against live ontology code)

Verified against `app/services/ontology/types/{deal,account,person}.py` and
`web/mcp/tools/ontology.py` on 2026-06-06. The deal type defines **26** expand keys
(not the 10 in the stale CLAUDE.md note). `insights` is **deprecated** and must not be
used. A computed **`meddpicc`** expand key exists.

**Verified tool signatures:**
- `ontology_resolve(type_name, object_id, expand=[...], expand_params={...})`
- `ontology_search(...)`, `ontology_list(...)`, `ontology_aggregate(...)`,
  `ontology_traverse(...)`, `search_transcripts(...)`
- (No `ontology_types` exposed over MCP — do not reference it.)

**Verified expand keys:**
- **deal:** `stakeholders, objections, commitments, competitors, meetings, strategy,
  emails, agent_summary, activity, meddpicc, pain_points, value_drivers, tactics,
  assessments, brief, artifacts, pipeline_stages, risks, outcome, closure_strategies,
  competitor_results, products, close_date_changes, recommendations, similar_deals`
  (plus deprecated `insights` — **do not use**).
- **account:** `deals, contacts, meetings, activity, sentiment`.
- **person:** `deals, meetings, insights, company, emails`.

**Per-skill binding:**

| Skill | Verified Doris binding |
|---|---|
| `account-research` | `ontology_resolve("account", id, expand=["deals","contacts","meetings","activity","sentiment"])` |
| `meeting-prep`, `discovery-planning` | deal `expand=["meetings","stakeholders","strategy","brief","recommendations","similar_deals","pain_points"]` |
| `discovery-call` | deal `expand=["pain_points","value_drivers","objections","tactics"]` |
| `post-call-followup` | deal `expand=["meetings","commitments","objections","stakeholders"]` + `search_transcripts` |
| `meddpicc-qualification` | deal `expand=["meddpicc","commitments","objections","competitors","stakeholders"]` |
| `deal-risk-review` | deal `expand=["risks","objections","commitments","activity","close_date_changes"]` |
| `competitive-battlecard` | deal `expand=["competitors","competitor_results","objections","value_drivers"]` + `search_transcripts` |
| `stakeholder-mapping`, `multithreading`, `champion-building` | deal `expand=["stakeholders","emails","activity"]`; person `expand=["deals","meetings","emails","company"]` |
| `forecast-hygiene` | `ontology_aggregate` (group_by stage/owner) + deal `expand=["close_date_changes","risks"]` |
| `pipeline-review`, `deal-review-prep` | `ontology_list` + `ontology_aggregate`; per-deal `expand=["brief","risks","commitments"]` |
| `crm-hygiene` | resolve deal, diff CRM fields vs. evidence expands, flag contradictions |
| `expansion-upsell`, `renewal-churn-save` | account `expand=["sentiment","activity"]`; deal `expand=["outcome","closure_strategies"]` |
| `proposal`, `business-case-roi`, `executive-briefing` | deal `expand=["brief","value_drivers","pain_points","stakeholders","commitments"]` |
| `mutual-action-plan`, `closing-plan` | deal `expand=["commitments","stakeholders","strategy","close_date_changes"]` |
| `objection-handling` | deal `expand=["objections","competitors","value_drivers"]` + `search_transcripts` |
| `negotiation` | deal `expand=["commitments","objections","value_drivers","products"]` |
| `demo-strategy` | deal `expand=["pain_points","value_drivers","stakeholders","products"]` |
| `prospecting`, `cold-email`, `sequence-writing`, `social-selling` | `ontology_search` for similar/won accounts; account/person expands for personalization |

This binding contract is the implementation source of truth — every "With Doris" block
must use only keys/tools verified here.

## Three-Tier Fallback Model

Fallbacks organize by **what kind of data a skill consumes**, not by tool brand, so
the methodology stays identical across tiers.

| Data the skill needs | Tier 1 — Doris (best) | Tier 2 — other MCP (good) | Tier 3 — nothing connected (works) |
|---|---|---|---|
| Conversation evidence (transcript, commitments, objections, pain points) | ontology expands + `search_transcripts` | Gong/Chorus/Fireflies MCP or transcript file | user pastes notes/transcript, or answers a short prompt |
| Deal / CRM fields (stage, amount, close date, contacts) | `ontology_resolve("deal", …)` | Salesforce / HubSpot MCP | user pastes a deal summary or answers 3–4 questions |
| Account & contact research | account/person expands | CRM MCP + Apollo/LinkedIn + web search | web search + user-provided company name |
| Email threads | `emails` expand | Gmail / Outlook MCP | user pastes the thread |
| Pipeline aggregates (forecast, reviews) | `ontology_aggregate` | CRM report/MCP | user pastes a pipeline export/CSV |

**Rules:**
- The "With Doris" block is always followed by "With a CRM/CI/email MCP" then "With
  nothing connected."
- **Tier 3 is always complete.** No skill is gated behind any integration.
- The product's value shows *because* the non-Doris path is visibly more manual.

Concrete examples:
- `post-call-followup` → Doris pulls extracted commitments; else paste the
  transcript/notes and the skill extracts them itself.
- `meddpicc-qualification` → Doris returns the `meddpicc` assessment; else the skill
  runs the qualification interactively from notes + asks for the gaps.
- `forecast-hygiene` → Doris aggregates; else paste your pipeline export and the same
  hygiene rules run.
- `account-research` → Doris account expand; else web search + CRM MCP, or just a
  company name.

## README Design

Graceful degradation is a **headline feature**. Proposed structure:

```markdown
# Sales Skills
AI agent skills for AEs — discovery, deal execution, forecasting, follow-up.

## Works with or without Doris
Every skill is fully functional on its own — paste your notes and go.
Connect an MCP and it gets sharper. Connect Doris and it gets sharpest.

| Tier | What you connect | What you get |
|------|------------------|--------------|
| ✅ Works | Nothing — just Claude | Full methodology, you provide the inputs |
| ⚡ Better | Your CRM / Gong / Gmail MCP | Skills pull live deal + conversation data |
| 🚀 Best | Doris (mcp.meetdoris.com) | Evidence-backed: real commitments, objections, risks, MEDDPICC, forecast |

[install] · [skill index — 30 skills by category] · [the Doris binding contract]
```

Each skill page ends with a **"Works without Doris"** note stating its Tier-3
behavior, plus a per-skill capability badge so the degradation is visible at a glance.

## Build Approach

The 30 skills are independent and homogeneous → ideal for **parallel authoring** once
the contract exists.

1. **Scaffold** the repo: structure, `.claude-plugin` manifest, LICENSE (MIT),
   `validate-skills.sh`, CI workflow, README skeleton, `CONTRIBUTING.md`, `AGENTS.md`,
   `CLAUDE.md`.
2. **Author `sales-context` + one reference skill** (`post-call-followup`) as the
   template/contract the rest conform to.
3. **Fan out** authoring the remaining 28 skills against the template (parallel agents
   / workflow — flag at execution time).
4. **Consistency pass**: every skill has all three binding tiers, a "Works without
   Doris" note, valid frontmatter with `Triggers on:`, and uses only verified
   expand keys/tools.
5. **Validation**: `validate-skills.sh` green in CI.
6. **README finalize**: tier table, full skill index, binding-contract appendix.

## Open Decisions (defaulted; veto in review)

- **Repo name:** `sales-skills` (decided). Standalone repo under the Doris-Labs
  GitHub org — not inside the monorepo. "GTM" reserved for a possible future umbrella
  spanning sales + marketing + CS skill sets.
- **Default framework:** MEDDPICC (defaulted).
- **Skill list:** the 30 above (no swaps; veto individual skills here).

## Success Criteria

- 30 skills, each with complete methodology + all three binding tiers + a "Works
  without Doris" note.
- Every "With Doris" block uses only keys/tools in the verified binding contract.
- `validate-skills.sh` passes in CI.
- README makes the with/without-Doris promise unmistakable.
- An AE with no Doris account can produce a real artifact from any skill.

## Risks / Mitigations

- **Stale ontology references over time.** Mitigation: binding contract appendix is the
  single source; a future check could diff "With Doris" blocks against the live
  `ExpandKeyDef`s. (Backlog candidate — file in Linear if pursued.)
- **Skill bloat / inconsistency across 30 files.** Mitigation: template-first build +
  consistency pass + validator.
- **Over-promising Tier-2 MCPs that don't exist.** Mitigation: Tier 2 stays
  brand-agnostic ("any CRM MCP"), never asserts a specific vendor MCP is available.
