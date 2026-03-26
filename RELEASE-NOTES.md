# Harness Builder Release Notes

## v1.0.0 (2026-03-25)

### Initial Release

First public release of the Harness Builder plugin — a GAN-inspired multi-agent architecture for Claude Code based on [Anthropic's Harness Design for Long-Running Apps](https://www.anthropic.com/engineering/harness-design-long-running-apps).

The core insight: AI agents that grade their own work produce mediocre output. By separating generation from evaluation with an information firewall, we get iterative improvement driven by independent, evidence-based scoring.

### What's Included

- **Four specialized agents**: Planner (prompt → spec), Contract Negotiator (testable success criteria), Generator (iterative builder), Evaluator (adversarial QA)
- **Information firewall**: Generator never sees evaluator's reasoning; evaluator never sees generator's self-assessment. Only actionable feedback bridges them.
- **Sprint contracts**: Before any code is written, agents negotiate testable criteria with verification methods and pass thresholds
- **Grading rubric**: 1-10 scoring calibration with concrete examples to prevent grade inflation
- **Iteration limits**: Max 5 iterations per sprint, 3 sprints per build (15 total cycles)
- **Slash command**: `/claude-harness-builder:build <your idea>` to invoke directly
- **Self-contained marketplace**: Plugin repo serves as its own marketplace for easy installation
