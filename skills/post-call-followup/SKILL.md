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

**Recap email template:**
```
Subject: <their problem> — next steps

Hi <name>,

Thanks for the time today. To recap what I heard: <their stated problem, their words>.

What we agreed:
- <value point that landed>
- Next step: <single clear ask> by <date>

<one-line close>
<signature>
```

**Both-sided commitments rule:** capture what *you* owe and what *they* owe. A recap
with only your commitments is a to-do list, not a mutual plan.

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
