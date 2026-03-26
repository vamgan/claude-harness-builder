---
name: harness-builder
description: Use when building complete applications or features from a brief 1-4 sentence prompt where quality matters more than speed. Triggers on "build me", "create an app", "implement from scratch", "make this production-ready", or when independent evaluation of generated work is needed. Do not use for simple bug fixes or single-file edits.
---

# Harness Builder

Build complete applications from brief prompts using a GAN-inspired multi-agent architecture that separates generation from evaluation.

**Core principle:** A generator that grades its own work produces mediocre output. Use independent evaluation with hard thresholds and negotiated success criteria (sprint contracts) to drive iterative improvement.

**Announce at start:** "I'm using the harness-builder skill to build this with independent quality evaluation."

## When to Use

```dot
digraph when_to_use {
    "Brief prompt (1-4 sentences)?" [shape=diamond];
    "Non-trivial app or feature?" [shape=diamond];
    "Quality over speed?" [shape=diamond];
    "harness-builder" [shape=box style=filled fillcolor=lightgreen];
    "Direct implementation" [shape=box];
    "subagent-driven-development" [shape=box];

    "Brief prompt (1-4 sentences)?" -> "Non-trivial app or feature?" [label="yes"];
    "Brief prompt (1-4 sentences)?" -> "Direct implementation" [label="no - simple task"];
    "Non-trivial app or feature?" -> "Quality over speed?" [label="yes"];
    "Non-trivial app or feature?" -> "Direct implementation" [label="no"];
    "Quality over speed?" -> "harness-builder" [label="yes"];
    "Quality over speed?" -> "subagent-driven-development" [label="no - have a plan already"];
}
```

## The Three Agents

| Agent | Role | Reads | Writes |
|-------|------|-------|--------|
| **Planner** | Expands brief prompt into full product spec | User prompt | `.harness/spec.md` |
| **Contract Negotiator** | Creates testable success criteria per sprint | Spec, prior eval reports | `.harness/contracts/sprint-N.md` |
| **Generator** | Implements iteratively, commits with git | Spec, contract, `feedback.md` | Code, `.harness/generation-report.md` |
| **Evaluator** | Independently tests using tools, scores with evidence | Spec, contract, running app | `.harness/evaluation-report.md`, `.harness/feedback.md` |

## The Workflow

```dot
digraph harness {
    rankdir=TB;

    "User provides brief prompt" [shape=box];
    "Init .harness/ workspace" [shape=box];
    "Dispatch Planner subagent" [shape=box];
    "Planner writes .harness/spec.md" [shape=box];
    "Present spec to user for approval" [shape=box style=filled fillcolor=lightyellow];

    subgraph cluster_sprint {
        label="Sprint Cycle (max 3 sprints)";
        style=dashed;
        "Dispatch Contract Negotiator" [shape=box];
        "Contract saved to .harness/contracts/sprint-N.md" [shape=box];

        subgraph cluster_gen_eval {
            label="Gen-Eval Loop (max 5 iterations)";
            style=dotted;
            "Dispatch Generator subagent" [shape=box];
            "Generator implements and commits" [shape=box];
            "Dispatch Evaluator subagent" [shape=box];
            "Evaluator scores with evidence" [shape=box];
            "All criteria pass?" [shape=diamond];
            "Feedback written to .harness/feedback.md" [shape=box];
        }
    }

    "Sprint complete" [shape=box];
    "More sprints needed?" [shape=diamond];
    "Present final results to user" [shape=box style=filled fillcolor=lightgreen];

    "User provides brief prompt" -> "Init .harness/ workspace";
    "Init .harness/ workspace" -> "Dispatch Planner subagent";
    "Dispatch Planner subagent" -> "Planner writes .harness/spec.md";
    "Planner writes .harness/spec.md" -> "Present spec to user for approval";
    "Present spec to user for approval" -> "Dispatch Contract Negotiator";
    "Dispatch Contract Negotiator" -> "Contract saved to .harness/contracts/sprint-N.md";
    "Contract saved to .harness/contracts/sprint-N.md" -> "Dispatch Generator subagent";
    "Dispatch Generator subagent" -> "Generator implements and commits";
    "Generator implements and commits" -> "Dispatch Evaluator subagent";
    "Dispatch Evaluator subagent" -> "Evaluator scores with evidence";
    "Evaluator scores with evidence" -> "All criteria pass?";
    "All criteria pass?" -> "Sprint complete" [label="yes OR max iterations"];
    "All criteria pass?" -> "Feedback written to .harness/feedback.md" [label="no"];
    "Feedback written to .harness/feedback.md" -> "Dispatch Generator subagent" [label="next iteration"];
    "Sprint complete" -> "More sprints needed?";
    "More sprints needed?" -> "Dispatch Contract Negotiator" [label="yes"];
    "More sprints needed?" -> "Present final results to user" [label="no"];
}
```

## File-Based Communication

All agent communication flows through `.harness/`. Run `scripts/init-harness.sh` to create the workspace.

```
.harness/
├── spec.md                  # Product specification (Planner output)
├── contracts/
│   └── sprint-N.md          # Sprint contract for sprint N
├── generation-report.md     # Generator's self-assessment (overwritten each iteration)
├── evaluation-report.md     # Evaluator's grading with evidence (overwritten each iteration)
├── feedback.md              # Evaluator's actionable feedback for generator (overwritten each iteration)
└── history.md               # Append-only log of all iterations with scores
```

Read `references/communication-protocol.md` for the full information firewall rules.

## Sprint Contract Negotiation

Before any implementation begins, the Contract Negotiator creates testable success criteria that both Generator and Evaluator will use. Read `references/sprint-contract-schema.md` for format details.

Each contract includes:
- 5-10 testable criteria with verification methods
- Tools the evaluator will use (shell commands, file reads, HTTP requests)
- Pass conditions (thresholds)
- Scope boundaries (what's in and out for this sprint)

For Sprint 1: focus on core functionality (MVP).
For Sprint 2+: address gaps from prior sprints, add remaining features.

## Quality Thresholds

Default pass conditions (can be overridden per sprint contract):

| Condition | Threshold |
|-----------|-----------|
| Each individual criterion | >= 7/10 |
| Overall average | >= 8/10 |
| Automatic fail floor | Any criterion < 5/10 |

Read `references/grading-rubric.md` for detailed scoring calibration with examples.

## Orchestrator Responsibilities

You (the main session) are the orchestrator. Your job:

1. **Initialize workspace** — Run `scripts/init-harness.sh` before dispatching any agents
2. **Dispatch agents sequentially** — Planner first, then contract negotiator, then generator/evaluator loop
3. **Enforce the information firewall:**
   - Generator reads: `spec.md`, `contracts/sprint-N.md`, `feedback.md`
   - Generator NEVER reads: `evaluation-report.md`
   - Evaluator reads: `spec.md`, `contracts/sprint-N.md`, running application
   - Evaluator NEVER reads: `generation-report.md`
4. **Present spec to user** — After planner finishes, show spec summary and ask for approval before proceeding
5. **Track iterations** — Use TodoWrite. Max 5 iterations per sprint, max 3 sprints
6. **Handle max iterations** — If thresholds not met after 5 iterations, present current state to user with honest assessment. Let user decide: continue, adjust thresholds, or accept as-is
7. **Append to history** — After each evaluation, append sprint/iteration number and scores to `.harness/history.md`

## Dispatching Agents

When dispatching each subagent, provide:

**Planner** (use `./agents/planner-prompt.md` as template):
- The user's original prompt verbatim
- The project working directory

**Contract Negotiator** (use `./agents/contract-negotiator-prompt.md` as template):
- Sprint number
- Path to spec file
- Previous evaluation report path (if sprint > 1)

**Generator** (use `./agents/generator-prompt.md` as template):
- Sprint and iteration number
- Paths to: spec, sprint contract, feedback (if iteration > 1)
- Project working directory

**Evaluator** (use `./agents/evaluator-prompt.md` as template):
- Sprint and iteration number
- Paths to: spec, sprint contract
- Project working directory
- How to start/access the running application

## Red Flags

Never:
- Let generator grade its own work as the final verdict
- Skip contract negotiation
- Continue past max iterations without user input
- Hide evaluator failures from the user
- Let evaluator access generator's self-review (independence is critical)
- Let generator access evaluator's full reasoning (only feedback.md)
- Start implementation without user approving the spec
- Dispatch generator and evaluator in parallel (they are sequential)
