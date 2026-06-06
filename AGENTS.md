# Agents guide

This repo is a collection of Claude skills for Account Executives. The skills are
designed to work together as an agentic toolkit, and they follow a few shared
conventions that make that composition reliable.

## sales-context is read first

The `sales-context` skill holds the foundational facts an AE keeps coming back to:
who the company sells to, the ICP, the sales motion, the stages of the pipeline,
the products, the competitors, and the AE's own deals in flight. Other skills
read this context before doing their own work, so that a discovery, qualification,
or follow-up skill doesn't have to re-establish the basics every time. Treat
`sales-context` as the shared memory layer the rest of the skills build on. If the
context isn't populated yet, skills should fall back to asking the AE directly.

## Skills auto-trigger on their `Triggers on:` phrases

Every skill declares a `description` in its frontmatter that ends with a
`Triggers on:` list of natural-language phrases. Those phrases are how a skill
gets selected automatically: when the AE's request matches one of them, the
corresponding skill activates without anyone naming it explicitly. Write trigger
phrases the way an AE actually talks ("prep me for this call", "is this deal
qualified", "draft a follow-up") so the right skill fires at the right moment.

## The three binding tiers degrade gracefully

Each skill can source its data at three levels of integration, and it always
degrades gracefully rather than failing:

1. **Doris (best).** The Doris ontology provides the richest, most-connected
   context — deals, stakeholders, commitments, objections, competitors, meetings,
   and emails resolved through a single typed layer. This is the recommended path.
2. **Any other MCP (better).** If Doris isn't connected but a CRM, a
   conversation-intelligence tool, or an email MCP is available, the skill uses
   that instead. Less complete than Doris, but a real upgrade over manual input.
3. **Nothing connected (still works).** With no integrations at all, the skill
   asks the AE for the inputs and works from pasted notes, transcripts, and
   memory. This path is always complete and functional — never a dead end.

The point is that these skills are useful to any AE on day one, and they get
sharper as more of the AE's stack is connected, with Doris as the best case.
