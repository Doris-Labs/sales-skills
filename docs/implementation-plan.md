# Sales Skills Repo Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build a standalone, open-source repo of 30 Claude skills for Account Executives, posture B (Doris as reference implementation), with every skill fully functional without any tool.

**Architecture:** A separate git repo (`sales-skills`) destined for the Doris-Labs GitHub org. Each skill is `skills/<name>/SKILL.md` following a fixed anatomy: methodology-first body + a three-tier tool-binding section (Doris → other MCP → manual) + a "Works without Doris" note. A `validate-skills.sh` linter enforces the anatomy and guards against deprecated ontology keys; CI runs it on every PR. `sales-context` + `post-call-followup` are authored first as the reference contract; the other 28 conform to them.

**Tech Stack:** Markdown + YAML frontmatter, Bash (validator), GitHub Actions (CI), `gh` CLI. No application code.

**Source spec:** `docs/superpowers/specs/2026-06-06-sales-skills-repo-design.md`

---

## File Structure

New repo built locally at `/Users/frazerkearl/sales-skills/`:

```
sales-skills/
├── .claude-plugin/plugin.json      # plugin manifest (name, description, version)
├── .github/workflows/validate.yml  # CI: run validate-skills.sh on PRs
├── skills/<name>/SKILL.md          # 30 skills, one folder each
├── AGENTS.md                       # how skills work together (agent-facing)
├── CLAUDE.md                       # repo conventions
├── CONTRIBUTING.md                 # how to add/improve a skill
├── LICENSE                         # MIT
├── README.md                       # purpose, install, tiered with/without-Doris story, skill index
├── VERSIONS.md                     # changelog
├── .gitignore
└── validate-skills.sh              # structural + binding linter
```

**Responsibilities:**
- `validate-skills.sh` — the single source of structural truth. Every skill must pass.
- `skills/sales-context/SKILL.md` — the context skill every other references first.
- `skills/post-call-followup/SKILL.md` — the worked reference template for all others.
- `README.md` — makes graceful degradation a headline feature.

**The verified Doris binding contract lives in the spec** (`§ Doris Binding Contract`). Every "With Doris" block uses only keys/tools verified there. The 26 valid deal expand keys; `insights` is **deprecated — never use**. Account keys: `deals, contacts, meetings, activity, sentiment`. Person keys: `deals, meetings, insights, company, emails`. Tools: `ontology_resolve(type_name, object_id, expand=[...], expand_params={...})`, `ontology_search`, `ontology_list`, `ontology_aggregate`, `ontology_traverse`, `search_transcripts`.

---

## Phase 1: Scaffold + Validator (the contract)

### Task 1: Initialize the repo

**Files:**
- Create: `/Users/frazerkearl/sales-skills/.gitignore`

- [ ] **Step 1: Create and init the repo**

```bash
mkdir -p /Users/frazerkearl/sales-skills/skills
cd /Users/frazerkearl/sales-skills
git init -b main
printf '.DS_Store\nnode_modules/\n*.log\n' > .gitignore
```

- [ ] **Step 2: Commit**

```bash
git add .gitignore
git commit -m "chore: init sales-skills repo"
```

---

### Task 2: Write the validator (write the failing check first)

**Files:**
- Create: `/Users/frazerkearl/sales-skills/validate-skills.sh`

- [ ] **Step 1: Write the validator**

Create `validate-skills.sh` with exactly this content:

```bash
#!/usr/bin/env bash
# Validates every skills/*/SKILL.md against the sales-skills anatomy.
set -uo pipefail

ROOT="$(cd "$(dirname "$0")" && pwd)"
SKILLS_DIR="$ROOT/skills"
fail=0

REQUIRED_HEADINGS=(
  "## Purpose"
  "## Inputs"
  "## Method"
  "## Tool binding"
  "### With Doris"
  "### With a CRM"
  "### With nothing connected"
  "## Works without Doris"
  "## Common mistakes"
)

if [ ! -d "$SKILLS_DIR" ]; then
  echo "ERROR: no skills/ directory"; exit 1
fi

shopt -s nullglob
count=0
for dir in "$SKILLS_DIR"/*/; do
  name="$(basename "$dir")"
  file="$dir/SKILL.md"
  count=$((count+1))

  if [ ! -f "$file" ]; then
    echo "FAIL [$name]: missing SKILL.md"; fail=1; continue
  fi

  # Frontmatter must start at line 1
  if [ "$(head -1 "$file")" != "---" ]; then
    echo "FAIL [$name]: file must start with YAML frontmatter (---)"; fail=1
  fi

  # name: must equal folder name
  fm_name="$(grep -m1 '^name:' "$file" | sed 's/^name:[[:space:]]*//')"
  if [ "$fm_name" != "$name" ]; then
    echo "FAIL [$name]: frontmatter name '$fm_name' != folder '$name'"; fail=1
  fi

  # description: present and contains a trigger phrase
  if ! grep -q '^description:' "$file"; then
    echo "FAIL [$name]: missing description in frontmatter"; fail=1
  fi
  if ! grep -qi 'Triggers on:' "$file"; then
    echo "FAIL [$name]: description must include 'Triggers on:'"; fail=1
  fi

  # Required headings
  for h in "${REQUIRED_HEADINGS[@]}"; do
    if ! grep -qF "$h" "$file"; then
      echo "FAIL [$name]: missing section '$h'"; fail=1
    fi
  done

  # Deprecated ontology key must never appear
  if grep -qE '"insights"|expand=\[[^]]*insights' "$file"; then
    echo "FAIL [$name]: uses deprecated expand key 'insights' (deal type)"; fail=1
  fi
done

if [ "$count" -eq 0 ]; then
  echo "ERROR: no skills found in $SKILLS_DIR"; exit 1
fi

if [ "$fail" -eq 0 ]; then
  echo "OK: $count skill(s) valid"
else
  echo "VALIDATION FAILED"
fi
exit $fail
```

- [ ] **Step 2: Make it executable and run it (expect failure — no skills yet)**

Run:
```bash
cd /Users/frazerkearl/sales-skills
chmod +x validate-skills.sh
./validate-skills.sh
```
Expected: `ERROR: no skills found` and exit code 1. This proves the validator detects the empty state.

- [ ] **Step 3: Commit**

```bash
git add validate-skills.sh
git commit -m "feat: add skill anatomy validator"
```

---

### Task 3: Repo meta files

**Files:**
- Create: `/Users/frazerkearl/sales-skills/LICENSE`
- Create: `/Users/frazerkearl/sales-skills/.claude-plugin/plugin.json`
- Create: `/Users/frazerkearl/sales-skills/.github/workflows/validate.yml`
- Create: `/Users/frazerkearl/sales-skills/CONTRIBUTING.md`
- Create: `/Users/frazerkearl/sales-skills/AGENTS.md`
- Create: `/Users/frazerkearl/sales-skills/CLAUDE.md`
- Create: `/Users/frazerkearl/sales-skills/VERSIONS.md`

- [ ] **Step 1: LICENSE** — standard MIT license text, copyright `2026 Doris Labs`.

- [ ] **Step 2: `.claude-plugin/plugin.json`**

```json
{
  "name": "sales-skills",
  "description": "AI agent skills for Account Executives — discovery, deal execution, qualification, forecasting, and follow-up. Works standalone; best with Doris.",
  "version": "0.1.0",
  "author": "Doris Labs",
  "skills": "./skills"
}
```

- [ ] **Step 3: `.github/workflows/validate.yml`**

```yaml
name: validate
on:
  pull_request:
  push:
    branches: [main]
jobs:
  validate:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Validate skills
        run: ./validate-skills.sh
```

- [ ] **Step 4: `CONTRIBUTING.md`** — document the skill anatomy (the 7 sections), the three-tier binding rule, the "Tier 3 must be complete" rule, and "run `./validate-skills.sh` before opening a PR."

- [ ] **Step 5: `AGENTS.md`** — explain that `sales-context` is read first, skills auto-trigger on their `Triggers on:` phrases, and the three binding tiers degrade gracefully.

- [ ] **Step 6: `CLAUDE.md`** — point Claude at `AGENTS.md` and the validator; note MIT license and that PRs must pass CI.

- [ ] **Step 7: `VERSIONS.md`** — `## 0.1.0 — initial 30 skills`.

- [ ] **Step 8: Commit**

```bash
git add LICENSE .claude-plugin .github CONTRIBUTING.md AGENTS.md CLAUDE.md VERSIONS.md
git commit -m "chore: add repo meta, plugin manifest, CI"
```

---

## Phase 2: Reference skills (the template)

### Task 4: Author `sales-context`

**Files:**
- Create: `/Users/frazerkearl/sales-skills/skills/sales-context/SKILL.md`

- [ ] **Step 1: Write the skill**

Frontmatter:
```yaml
---
name: sales-context
description: Foundational context every sales skill reads first — the AE's ICP, deal sizes, sales motion, qualification framework, and which tools/MCPs are connected. Use at the start of any sales task. Triggers on: sales context, set up sales, my pipeline, who do I sell to, which tools are connected.
---
```

Body must contain all required headings. Content:
- **Purpose:** establish shared context so other skills don't re-ask. Defines the AE profile, ICP, average deal size/cycle, default framework (MEDDPICC), and a tool inventory.
- **Inputs:** the user's product, ICP, deal motion; optionally a connected MCP.
- **Method:** a short interview to capture/persist context (product, ICP, ACV, sales cycle, stages, competitors). State that MEDDPICC is the default framework and how its elements map to evidence.
- **Tool binding:**
  - *With Doris (recommended):* register Doris as the connected substrate; note `ontology_resolve`/`ontology_list`/`ontology_aggregate`/`search_transcripts` are available; account/person/deal expand keys can be pulled by downstream skills.
  - *With a CRM / CI / email MCP:* note any connected CRM/conversation-intelligence/email MCP as the substrate.
  - *With nothing connected:* capture context from the user directly; downstream skills will ask for inputs.
- **Works without Doris:** one line — context is captured interactively; nothing requires Doris.
- **Common mistakes:** re-asking context other skills already captured; assuming a framework the user doesn't run.

- [ ] **Step 2: Run validator (expect pass for this skill, fail overall until others exist is fine — run targeted check)**

Run:
```bash
cd /Users/frazerkearl/sales-skills && ./validate-skills.sh
```
Expected: `OK: 1 skill(s) valid` (only sales-context exists so far).

- [ ] **Step 3: Commit**

```bash
git add skills/sales-context
git commit -m "feat(skill): sales-context foundation skill"
```

---

### Task 5: Author `post-call-followup` (the worked reference template)

**Files:**
- Create: `/Users/frazerkearl/sales-skills/skills/post-call-followup/SKILL.md`

- [ ] **Step 1: Write the skill** with this exact content as the canonical template all others mirror:

````markdown
---
name: post-call-followup
description: Turn a sales call into a follow-up email, clear next steps, and a clean CRM update. Use after a discovery, demo, or any customer call. Triggers on: follow up email, post call, recap email, log this call, update the deal.
---

# Post-Call Follow-Up

## Purpose
Turn a just-finished call into three artifacts: a recap email the buyer actually
wants, clear mutual next steps, and a CRM update that keeps the deal honest.

## Inputs
- What was discussed (transcript, notes, or your recollection)
- Who was on the call and their role
- The deal's current stage and what you're trying to advance

## Method
1. Extract the spine of the call: pains named, value landed, objections raised,
   commitments made (by both sides), and the agreed next step.
2. Draft the recap email in the buyer's language — lead with their stated problem,
   mirror their words, make the next step a single clear ask. Keep it under 150 words.
3. Write next steps as `owner + action + date`. No orphaned tasks.
4. Produce the CRM update: stage check, MEDDPICC slot changes, next-step field, new
   stakeholders. Flag any field the call *contradicts*.

[Include: a recap-email template, a rule for capturing both-sided commitments, and an
example of an evidence-backed CRM update.]

## Tool binding
This skill works from raw notes alone. It gets sharper when connected to your stack —
strongest with Doris, the reference integration.

### With Doris (recommended)
If the Doris MCP (`mcp.meetdoris.com`) is connected, pull the call directly instead of
asking the user to paste notes:
- `ontology_resolve("deal", id, expand=["meetings","commitments","objections","stakeholders"])`
  — use the real transcript-derived commitments and existing deal context so the recap
  reflects what was *actually said* and the CRM update is evidence-backed.
- `search_transcripts(...)` to quote exact buyer language.
Doris already extracts commitments, objections, and stakeholders per call — prefer
those over re-deriving from raw text.

### With a CRM / CI / email MCP
- Conversation-intelligence MCP (Gong/Chorus/Fireflies) or a transcript file → source
  the call content.
- CRM MCP (Salesforce/HubSpot) → write the stage/field updates back directly.

### With nothing connected
Ask the user to paste notes or the transcript; extract commitments yourself; output the
email, next steps, and a copy-paste CRM update block.

## Works without Doris
Fully functional from pasted notes — Doris only removes the paste step and supplies
evidence-backed commitments.

## Common mistakes
- Recap written in seller language, not the buyer's.
- Next steps with no owner or date.
- CRM update that restates the stage instead of flagging contradictions.
````

- [ ] **Step 2: Run validator**

Run:
```bash
cd /Users/frazerkearl/sales-skills && ./validate-skills.sh
```
Expected: `OK: 2 skill(s) valid`.

- [ ] **Step 3: Commit**

```bash
git add skills/post-call-followup
git commit -m "feat(skill): post-call-followup reference template"
```

---

## Phase 3: Author the remaining 28 skills

Each task below = create `skills/<name>/SKILL.md` following the Task 5 template exactly
(same 7 required sections, three binding tiers, "Works without Doris" note), then run
`./validate-skills.sh` (expect `OK` with the running count) and commit
`feat(skill): <name>`. These 28 are independent and can be authored in parallel by
subagents; each subagent gets the Task 5 template + the brief below + the spec's binding
contract.

**Authoring rules for every skill:**
- Method section carries real frameworks/templates — no hand-waving.
- "With Doris" block uses **only** the binding row given (verified keys/tools).
- Tier 3 is always a complete manual path.
- `description` ends with `Triggers on:` + 3-5 phrases.

---

### Task 6: `account-research`
- **Triggers:** research this account, company research, account brief, who are they.
- **Method:** firmographics, recent triggers (funding/hiring/news), org structure, likely pains mapped to your product, hypotheses to test on the call.
- **Doris:** `ontology_resolve("account", id, expand=["deals","contacts","meetings","activity","sentiment"])`.
- **Tier 2:** CRM MCP + Apollo/LinkedIn + web search. **Tier 3:** web search + a company name.

### Task 7: `prospecting`
- **Triggers:** build a prospect list, find accounts, who to target, prospecting.
- **Method:** ICP filtering, account scoring, trigger-based prioritization, entry-point selection (persona to open with).
- **Doris:** `ontology_search` for similar/won accounts to pattern-match ICP.
- **Tier 2:** CRM/Apollo MCP. **Tier 3:** user provides ICP criteria; produce a target profile + sourcing checklist.

### Task 8: `cold-email`
- **Triggers:** cold email, write outreach, first touch email, break in.
- **Method:** one-problem-per-email, relevance hook from a trigger, short ask, no feature-dumping; 3 example variants.
- **Doris:** account/person expands for personalization; `ontology_search` for proof from similar wins.
- **Tier 2:** CRM/Gmail MCP for contact + thread. **Tier 3:** user gives prospect + trigger; output 3 variants.

### Task 9: `sequence-writing`
- **Triggers:** build a sequence, cadence, multi-touch, follow-up sequence.
- **Method:** multi-touch cadence design (channel mix, spacing, message angle per touch, breakup email), value-per-touch rule.
- **Doris:** account/person expands for personalization tokens.
- **Tier 2:** Outreach/Salesloft/Gmail MCP. **Tier 3:** output a copy-paste cadence with timing.

### Task 10: `social-selling`
- **Triggers:** LinkedIn outreach, social selling, connection request, comment strategy.
- **Method:** profile-led engagement, connection-note formula, content-comment cadence, warm-intro paths.
- **Doris:** person expand (`company`, `deals`) for relationship context.
- **Tier 2:** LinkedIn/CRM MCP. **Tier 3:** user provides the profile; output notes + engagement plan.

### Task 11: `meeting-prep`
- **Triggers:** prep for my meeting, meeting prep, prep this call, call brief.
- **Method:** attendee research, agenda, hypotheses, landmines, desired next step; one-page brief format.
- **Doris:** deal `expand=["meetings","stakeholders","strategy","brief","recommendations","similar_deals","pain_points"]`.
- **Tier 2:** CRM + calendar + CI MCP. **Tier 3:** user gives attendees + deal stage.

### Task 12: `discovery-planning`
- **Triggers:** plan discovery, discovery questions, what to ask, discovery prep.
- **Method:** question tree by hypothesis, pain → impact → priority laddering, multi-threading targets to surface.
- **Doris:** deal `expand=["meetings","stakeholders","strategy","brief","recommendations","similar_deals","pain_points"]`.
- **Tier 2:** CRM/CI MCP. **Tier 3:** user gives the account + goal; output a question plan.

### Task 13: `discovery-call`
- **Triggers:** run discovery, discovery framework, lead the call, qualify on the call.
- **Method:** live question frameworks (situation → problem → implication → need), pain quantification, talk-ratio discipline, capturing next step in-call.
- **Doris:** deal `expand=["pain_points","value_drivers","objections","tactics"]`.
- **Tier 2:** CI MCP for live/recent context. **Tier 3:** user describes the deal; output a runnable structure.

### Task 14: `stakeholder-mapping`
- **Triggers:** map stakeholders, buying committee, who else, power map.
- **Method:** role/influence/sentiment grid, champion vs blocker vs neutral, coverage gaps, access plan.
- **Doris:** deal `expand=["stakeholders","emails","activity"]`; person `expand=["deals","meetings","emails","company"]`.
- **Tier 2:** CRM MCP. **Tier 3:** user lists contacts; output a power map + gaps.

### Task 15: `demo-strategy`
- **Triggers:** plan the demo, demo strategy, tailor the demo, demo prep.
- **Method:** discovery-driven demo (only show what maps to a named pain), tell-show-tell, "so what" per feature, planned wow moment.
- **Doris:** deal `expand=["pain_points","value_drivers","stakeholders","products"]`.
- **Tier 2:** CRM/CI MCP. **Tier 3:** user gives pains + audience; output a demo flow.

### Task 16: `objection-handling`
- **Triggers:** handle objection, they said, pushback, objection response.
- **Method:** acknowledge → clarify → reframe → evidence, library of common objection patterns (price, status quo, timing, competitor), real responses.
- **Doris:** deal `expand=["objections","competitors","value_drivers"]` + `search_transcripts`.
- **Tier 2:** CI MCP for the exact quote. **Tier 3:** user pastes the objection; output a response.

### Task 17: `mutual-action-plan`
- **Triggers:** mutual action plan, MAP, close plan with buyer, joint plan.
- **Method:** backward-planned milestones from go-live, owners on both sides, decision/procurement/legal steps, shared-doc format.
- **Doris:** deal `expand=["commitments","stakeholders","strategy","close_date_changes"]`.
- **Tier 2:** CRM MCP. **Tier 3:** user gives target date + steps; output a MAP table.

### Task 18: `competitive-battlecard`
- **Triggers:** battlecard, competitor, vs [competitor], compete against.
- **Method:** where-we-win/where-they-win, landmines to set, trap questions, objection rebuttals — honest, not spin.
- **Doris:** deal `expand=["competitors","competitor_results","objections","value_drivers"]` + `search_transcripts`.
- **Tier 2:** CI MCP for mentions. **Tier 3:** user names the competitor; output a battlecard.

### Task 19: `negotiation`
- **Triggers:** negotiate, discount, pricing pushback, close the terms.
- **Method:** trade-don't-cave, concession ladder, anchoring, protect price with value, get something for every give.
- **Doris:** deal `expand=["commitments","objections","value_drivers","products"]`.
- **Tier 2:** CRM MCP. **Tier 3:** user gives the ask; output a negotiation plan.

### Task 20: `meddpicc-qualification`
- **Triggers:** qualify this deal, MEDDPICC, is this real, qualification gaps.
- **Method:** score each MEDDPICC element, evidence vs assumption per element, gaps → next actions; note BANT/SPICED alternatives.
- **Doris:** deal `expand=["meddpicc","commitments","objections","competitors","stakeholders"]` — pull the existing assessment; else run interactively.
- **Tier 2:** CRM/CI MCP. **Tier 3:** interview the user element-by-element.

### Task 21: `deal-risk-review`
- **Triggers:** is this deal at risk, deal health, risk review, will this close.
- **Method:** risk taxonomy (single-threaded, no economic buyer, no next step, stalled, competitor active), severity, mitigation per risk.
- **Doris:** deal `expand=["risks","objections","commitments","activity","close_date_changes"]`.
- **Tier 2:** CRM/CI MCP. **Tier 3:** user describes the deal; run the risk checklist.

### Task 22: `champion-building`
- **Triggers:** build a champion, do I have a champion, develop my champion, coach them.
- **Method:** champion vs coach test, enablement assets, give-to-get, testing the champion's power.
- **Doris:** deal `expand=["stakeholders","emails","activity"]`.
- **Tier 2:** CRM MCP. **Tier 3:** user names the contact; output a champion-development plan.

### Task 23: `multithreading`
- **Triggers:** multithread, single threaded, reach more people, widen the deal.
- **Method:** coverage analysis vs buying committee, intro paths from current contacts, per-persona value angle.
- **Doris:** deal `expand=["stakeholders","emails","activity"]`; person `expand=["deals","meetings","emails","company"]`.
- **Tier 2:** CRM MCP. **Tier 3:** user lists current contacts; output a threading plan.

### Task 24: `closing-plan`
- **Triggers:** close plan, how do I close, path to close, get this signed.
- **Method:** steps-to-signature, procurement/legal/security gates, time-boxed asks, contingency if a gate slips.
- **Doris:** deal `expand=["commitments","stakeholders","strategy","close_date_changes"]`.
- **Tier 2:** CRM MCP. **Tier 3:** user gives the target date; output a closing checklist.

### Task 25: `deal-review-prep`
- **Triggers:** deal review prep, prep for 1:1, manager review, pipeline 1:1.
- **Method:** per-deal one-liner (stage, next step, risk, ask), what the manager will probe, what help to request.
- **Doris:** `ontology_list` + `ontology_aggregate`; per-deal `expand=["brief","risks","commitments"]`.
- **Tier 2:** CRM MCP. **Tier 3:** user pastes their deal list; output review notes.

### Task 26: `forecast-hygiene`
- **Triggers:** forecast, is my forecast clean, commit vs best case, sandbag.
- **Method:** category discipline (commit/best-case/pipeline), evidence test per deal, close-date sanity, slip detection.
- **Doris:** `ontology_aggregate` (group_by stage/owner) + deal `expand=["close_date_changes","risks"]`.
- **Tier 2:** CRM report/MCP. **Tier 3:** user pastes a pipeline export; apply the hygiene rules.

### Task 27: `pipeline-review`
- **Triggers:** review my pipeline, pipeline health, coverage, what's stuck.
- **Method:** coverage ratio, stage distribution, aging/stalled detection, next-action gaps.
- **Doris:** `ontology_list` + `ontology_aggregate`.
- **Tier 2:** CRM MCP. **Tier 3:** user pastes pipeline data; output a health summary.

### Task 28: `crm-hygiene`
- **Triggers:** clean up CRM, CRM hygiene, update my deals, stale fields.
- **Method:** field-by-field staleness/contradiction checks, next-step presence, stage-vs-evidence mismatch; write-back proposals.
- **Doris:** resolve deal, diff CRM fields vs evidence expands (`commitments`, `meetings`, `stakeholders`), flag contradictions.
- **Tier 2:** CRM MCP for write-back. **Tier 3:** user pastes deal fields; output a correction list.

### Task 29: `expansion-upsell`
- **Triggers:** expansion, upsell, grow this account, cross-sell.
- **Method:** whitespace mapping, usage/sentiment signals, expansion triggers, land-and-expand play.
- **Doris:** account `expand=["sentiment","activity"]`; deal `expand=["outcome","closure_strategies"]`.
- **Tier 2:** CRM/product-usage MCP. **Tier 3:** user describes the account; output an expansion plan.

### Task 30: `renewal-churn-save`
- **Triggers:** renewal, churn risk, save this account, at-risk customer.
- **Method:** renewal-risk signals, value-realization recap, save play, escalation path.
- **Doris:** account `expand=["sentiment","activity"]`; deal `expand=["outcome","closure_strategies"]`.
- **Tier 2:** CRM/CS-tool MCP. **Tier 3:** user describes the account; output a renewal plan.

### Task 31: `business-case-roi`
- **Triggers:** business case, ROI, justify the spend, value model.
- **Method:** cost-of-inaction, value drivers → quantified impact, conservative ROI model, payback period.
- **Doris:** deal `expand=["brief","value_drivers","pain_points","stakeholders","commitments"]`.
- **Tier 2:** CRM MCP. **Tier 3:** user gives metrics; output an ROI model + narrative.

### Task 32: `proposal`
- **Triggers:** write a proposal, proposal, SOW, quote document.
- **Method:** problem → solution → scope → pricing → next steps, mirror the buyer's stated priorities, single clear CTA.
- **Doris:** deal `expand=["brief","value_drivers","pain_points","stakeholders","commitments"]`.
- **Tier 2:** CRM MCP. **Tier 3:** user gives scope + price; output a proposal draft.

### Task 33: `executive-briefing`
- **Triggers:** executive summary, brief the exec, C-level summary, board-ready.
- **Method:** one-page exec format — outcome first, business impact, ask, risks; ruthless brevity.
- **Doris:** deal `expand=["brief","value_drivers","pain_points","stakeholders","commitments"]`.
- **Tier 2:** CRM MCP. **Tier 3:** user gives deal facts; output an exec brief.

---

## Phase 4: Consistency, README, ship

### Task 34: Full consistency pass + validation

**Files:**
- Modify: any `skills/*/SKILL.md` that fails.

- [ ] **Step 1: Run the validator across all 30**

Run:
```bash
cd /Users/frazerkearl/sales-skills && ./validate-skills.sh
```
Expected: `OK: 30 skill(s) valid`.

- [ ] **Step 2: Spot-check binding accuracy** — grep for any expand key not in the verified set and for accidental `insights` use:

```bash
grep -rn 'insights' skills/ || echo "no insights refs — good"
grep -rohE 'expand=\[[^]]*\]' skills/ | sort -u
```
Expected: no `insights`; every key in the printed list appears in the spec's verified set (deal/account/person). Fix any stray key.

- [ ] **Step 3: Commit any fixes**

```bash
git add skills && git commit -m "fix(skills): consistency pass — binding + anatomy"
```

### Task 35: README + skill index

**Files:**
- Create: `/Users/frazerkearl/sales-skills/README.md`

- [ ] **Step 1: Write README** with: one-line purpose; the "Works with or without Doris" tier table (✅ Works / ⚡ Better / 🚀 Best); install instructions (clone into the agent's skills/plugin path); the 30-skill index grouped by the 8 categories; and a "Doris binding contract" appendix summarizing the verified expand keys.

- [ ] **Step 2: Commit**

```bash
git add README.md && git commit -m "docs: README with tiered with/without-Doris story + skill index"
```

### Task 36: Publish to Doris-Labs (requires explicit user go-ahead)

- [ ] **Step 1: Create the remote (private) and push** — confirm with the user first; this is an outward action.

```bash
cd /Users/frazerkearl/sales-skills
gh repo create Doris-Labs/sales-skills --private --source=. --remote=origin --push
```
Expected: repo created under the org, `main` pushed, CI runs `validate-skills.sh` green.

- [ ] **Step 2: Flip to public at launch** — separate, explicit user decision later (`gh repo edit Doris-Labs/sales-skills --visibility public`).

---

## Self-Review

**Spec coverage:**
- Repo structure → Tasks 1, 3. ✅
- Skill anatomy (7 sections) → Task 5 template + validator Task 2. ✅
- 30 skills → Tasks 4, 5, 6–33 (1 + 1 + 28 = 30). ✅
- Verified Doris binding contract → embedded per-skill brief + Task 34 grep check. ✅
- Three-tier fallback → required headings in validator + every brief. ✅
- README tiered story → Task 35. ✅
- MIT license / plugin manifest / CI → Task 3. ✅
- Build approach (scaffold → template → fan out → consistency → validate) → Phases 1–4. ✅
- Repo name `sales-skills`, Doris-Labs org → Task 36. ✅

**Placeholder scan:** No "TBD/TODO"; method briefs name real frameworks; validator and templates are complete code. The bracketed `[Include: ...]` notes in Task 5 are authoring guidance inside the reference skill body, not plan placeholders — the executor expands them into prose.

**Type/name consistency:** `validate-skills.sh` name and required-heading strings match across Tasks 2, 4, 5, 34. Expand keys match the spec's verified set. Skill count reconciles to 30.
