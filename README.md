# Harness Builder — Claude Code Skill

A Claude Code skill that builds complete applications from brief prompts using a GAN-inspired multi-agent architecture. Based on Anthropic's engineering article [Harness Design for Long-Running Apps](https://www.anthropic.com/engineering/harness-design-long-running-apps).

## The Problem

When AI agents work on long tasks, two failure modes emerge:

1. **Context Loss** — Models lose coherence as context windows fill up
2. **Self-Evaluation Bias** — Agents praise their own mediocre work

## The Solution

Separate generation from evaluation using three specialized agents with file-based communication:

```
User Prompt
    ↓
[Planner] → spec.md
    ↓
[Contract Negotiator] → sprint contract
    ↓
┌──────────────────────────┐
│  Generation-Evaluation   │
│  Loop (max 5 iterations) │
│                          │
│  [Generator] → code      │
│       ↓                  │
│  [Evaluator] → scores    │
│       ↓                  │
│  Pass? → next sprint     │
│  Fail? → feedback → loop │
└──────────────────────────┘
```

Key design principles:
- **Information firewall**: Generator never sees evaluator's reasoning; evaluator never sees generator's self-assessment
- **Sprint contracts**: Testable success criteria agreed upon before implementation
- **File-based communication**: Each agent gets fresh context, reads only what it needs
- **Hard thresholds**: Average score >= 8/10, no criterion below 7/10

## Installation

### As a local Claude Code skill

```bash
# Clone to your Claude skills directory
mkdir -p ~/.claude/skills
cp -r . ~/.claude/skills/harness-builder/
```

### From GitHub

```bash
git clone https://github.com/vamgan/claude-harness-builder.git
cp -r claude-harness-builder ~/.claude/skills/harness-builder/
```

## Usage

The skill triggers automatically in Claude Code when you say things like:

- "Build me a recipe sharing app"
- "Create an app that tracks my workouts"
- "Implement a dashboard from scratch"

Or you can reference it directly. The skill will:

1. Expand your brief prompt into a full product spec
2. Present the spec for your approval
3. Negotiate sprint contracts with testable criteria
4. Build iteratively with independent quality evaluation
5. Loop until quality thresholds are met or present results for your decision

## Architecture

```
harness-builder/
├── SKILL.md                           # Main orchestrator instructions
├── agents/
│   ├── planner-prompt.md              # Expands prompt → product spec
│   ├── generator-prompt.md            # Implements iteratively
│   ├── evaluator-prompt.md            # Independent QA with evidence
│   └── contract-negotiator-prompt.md  # Negotiates testable criteria
├── references/
│   ├── sprint-contract-schema.md      # Contract format and examples
│   ├── communication-protocol.md      # File layout and firewall rules
│   └── grading-rubric.md              # Scoring calibration (1-10)
└── scripts/
    └── init-harness.sh                # Creates .harness/ workspace
```

## How It Works

### The Information Firewall

The generator and evaluator never see each other's internal reasoning. Only `feedback.md` (actionable instructions) bridges them. This prevents:
- **Gaming**: Generator can't learn to exploit evaluator's scoring logic
- **Anchoring**: Evaluator isn't biased by generator's self-scores

### Sprint Contracts

Before implementation, criteria are negotiated:

| # | Criterion | Verification Method | Threshold |
|---|-----------|-------------------|-----------|
| 1 | Server starts without errors | `npm start && curl localhost:3000` | 7/10 |
| 2 | POST /api/items returns 201 | `curl -X POST ...` | 7/10 |
| 3 | Invalid input returns 400 | `curl -X POST -d '{}'` | 7/10 |

### Iteration Limits

- Max 5 iterations per sprint
- Max 3 sprints per build
- If thresholds aren't met: user decides next steps

## Credits

Based on the [Harness Design for Long-Running Apps](https://www.anthropic.com/engineering/harness-design-long-running-apps) article from Anthropic Engineering, which describes a GAN-inspired approach to separating generation from evaluation in AI agent workflows.

## License

MIT
