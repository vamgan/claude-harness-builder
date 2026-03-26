# Communication Protocol

## Overview

All agent communication flows through files in `.harness/`. Agents never communicate directly. The orchestrator (main session) dispatches agents sequentially and controls what each agent can read.

## Directory Structure

```
.harness/
├── spec.md                  # Product specification
├── contracts/
│   ├── sprint-1.md          # Sprint 1 contract
│   ├── sprint-2.md          # Sprint 2 contract
│   └── sprint-3.md          # Sprint 3 contract
├── generation-report.md     # Generator's self-assessment (current iteration)
├── evaluation-report.md     # Evaluator's grading (current iteration)
├── feedback.md              # Evaluator's actionable feedback (current iteration)
└── history.md               # Append-only log of all iterations
```

## Information Firewall

This is the most critical aspect of the harness. The separation prevents gaming and anchoring bias.

### Generator Can Read
- `.harness/spec.md` — the product specification
- `.harness/contracts/sprint-N.md` — current sprint's contract
- `.harness/feedback.md` — evaluator's actionable feedback (iteration > 1 only)

### Generator CANNOT Read
- `.harness/evaluation-report.md` — evaluator's full reasoning and scores
  - **Why:** If the generator sees the evaluator's internal reasoning, it can learn to game the evaluation criteria rather than genuinely improving the work.

### Evaluator Can Read
- `.harness/spec.md` — the product specification
- `.harness/contracts/sprint-N.md` — current sprint's contract
- The actual code and running application

### Evaluator CANNOT Read
- `.harness/generation-report.md` — generator's self-assessment
  - **Why:** If the evaluator sees the generator's self-scores, it anchors on them. A generator claiming 9/10 biases the evaluator toward confirming that score rather than independently assessing.

### The Bridge: feedback.md

`feedback.md` is the controlled channel between Evaluator and Generator:
- Written by: Evaluator
- Read by: Generator (next iteration only)
- Contains: Actionable instructions without full reasoning
- Format: Must Fix / Should Improve / Working Well

## File Lifecycle

### Per Iteration
1. Generator writes `generation-report.md` (overwrites previous)
2. Evaluator writes `evaluation-report.md` (overwrites previous)
3. Evaluator writes `feedback.md` (overwrites previous)
4. Orchestrator appends summary to `history.md`

### Per Sprint
1. Contract Negotiator writes `contracts/sprint-N.md` (new file)

### Once
1. Planner writes `spec.md` (written once, read by all agents)

## History Log Format

The orchestrator appends to `.harness/history.md` after each evaluation:

```markdown
## Sprint N, Iteration M — [PASS/FAIL]
- Date: YYYY-MM-DD HH:MM
- Overall Score: X.X/10
- Criteria Scores: [C1: X, C2: X, C3: X, ...]
- Verdict: PASS/FAIL
- Key Issues: [brief summary if FAIL]
```

## Orchestrator Mediation

The orchestrator's role in communication:

1. **Dispatch planner** with user's original prompt
2. **Present spec** to user, wait for approval
3. **Dispatch contract negotiator** with spec path (and prior eval if sprint > 1)
4. **Dispatch generator** with spec + contract + feedback paths
5. **Dispatch evaluator** with spec + contract paths (NOT generation-report)
6. **Read evaluation-report**, append to history
7. **If FAIL and iterations remain:** go to step 4
8. **If PASS or max iterations:** proceed to next sprint or finish
